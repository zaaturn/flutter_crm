import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_app/auth/auth_session.dart';
import 'package:my_app/auth/admin_landing.dart';
import 'package:my_app/auth/profile_remote_sync.dart';
import 'package:my_app/core/auth/auth_session_redirect.dart';
import 'package:my_app/core/auth/jwt_utils.dart';
import 'package:my_app/core/auth/admin_access_guard.dart';
import 'package:my_app/core/auth/shell_route_persistence.dart';
import 'package:my_app/services/api_client.dart';
import 'package:my_app/services/secure_storage_service.dart';

class StartupGate extends StatefulWidget {
  const StartupGate({super.key});

  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  static const _storageTimeout = Duration(seconds: 12);

  Future<void> _redirectToLogin() async {
    if (!mounted) return;
    await AuthSessionRedirect.logoutAndGoToLogin(context: context);
  }

  void _goEmployee() {
    Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
      ShellRoutePersistence.employee,
      (route) => false,
    );
  }

  void _goAdmin() {
    Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
      ShellRoutePersistence.admin,
      (route) => false,
    );
  }

  Future<void> _prepareRestrictedLanding(AuthSession? session) async {
    if (session == null) {
      AdminLandingIntent.setPending(null);
      return;
    }
    if (session.hasRestrictedAdminModules) {
      AdminLandingIntent.setPending(session.firstAssignedSidebarAction);
    } else {
      AdminLandingIntent.setPending(null);
    }
  }

  void _goChooser() {
    Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
      '/dashboardChooser',
      (route) => false,
    );
  }

  Future<void> _routeToShell({
    required AuthSession? session,
    required bool legacySuperuser,
    required String role,
    required String? activeDashboardRaw,
    required String? lastShellRoute,
  }) async {
    final canAccessAdmin = AdminAccessGuard.allows(
      session: session,
      role: role,
      legacySuperuser: legacySuperuser,
    );
    final active = ActiveDashboardStorage.fromString(activeDashboardRaw);

    // Restore the last shell the user was actually viewing.
    if (lastShellRoute == ShellRoutePersistence.employee) {
      await ShellRoutePersistence.markEmployeeShell();
      if (!mounted) return;
      _goEmployee();
      return;
    }

    if (lastShellRoute == ShellRoutePersistence.admin && canAccessAdmin) {
      await _prepareRestrictedLanding(session);
      await ShellRoutePersistence.markAdminShell();
      if (!mounted) return;
      _goAdmin();
      return;
    }

    if (canAccessAdmin) {
      final dash = active ?? ActiveDashboard.admin;
      if (dash == ActiveDashboard.employee) {
        await ShellRoutePersistence.markEmployeeShell();
        if (!mounted) return;
        _goEmployee();
        return;
      }
      if (dash == ActiveDashboard.admin) {
        await _prepareRestrictedLanding(session);
        await ShellRoutePersistence.markAdminShell();
        if (!mounted) return;
        _goAdmin();
        return;
      }
      if (!mounted) return;
      _goChooser();
      return;
    }

    await ShellRoutePersistence.markEmployeeShell();
    if (!mounted) return;
    _goEmployee();
  }

  Future<void> _checkAuth() async {
    final storage = SecureStorageService();

    String? token;
    String? activeDashboardRaw;
    String? lastShellRoute;

    try {
      token = await storage.readToken().timeout(_storageTimeout);
      activeDashboardRaw =
          await storage.readActiveDashboard().timeout(_storageTimeout);
      lastShellRoute =
          await storage.readLastShellRoute().timeout(_storageTimeout);
    } on TimeoutException {
      token = null;
      activeDashboardRaw = null;
      lastShellRoute = null;
    } catch (_) {
      token = null;
      activeDashboardRaw = null;
      lastShellRoute = null;
    }

    final accessExpired =
        token != null && token.isNotEmpty && JwtUtils.isExpired(token);

    if (token == null || token.isEmpty || accessExpired) {
      final refresh = await storage.readRefreshToken().timeout(_storageTimeout);
      if (refresh != null && refresh.isNotEmpty) {
        try {
          final ok = await ApiClient().ensureSessionValid(redirectOnFailure: false);
          if (ok) {
            ApiClient().forceAuthenticated();
            token = await storage.readToken().timeout(_storageTimeout);
          } else {
            token = null;
          }
        } catch (_) {
          token = null;
        }
      } else if (accessExpired) {
        token = null;
      }
    } else {
      ApiClient().forceAuthenticated();
    }

    if (!mounted) return;

    if (token == null || token.isEmpty) {
      await _redirectToLogin();
      return;
    }

    await ProfileRemoteSync.syncFromServer();

    String? roleStr;
    String? sessionJson;
    var legacySuperuser = false;

    try {
      sessionJson = await storage.readAuthSessionJson().timeout(_storageTimeout);
      roleStr = await storage.readRole().timeout(_storageTimeout);
      legacySuperuser = await storage.readIsSuperuser().timeout(_storageTimeout);
    } on TimeoutException {
      sessionJson = null;
      roleStr = null;
      legacySuperuser = false;
    } catch (_) {
      sessionJson = null;
      roleStr = null;
      legacySuperuser = false;
    }

    if (!mounted) return;

    final session = AuthSession.fromStorageString(sessionJson);
    final isSuperuser =
        session?.isSuperuser == true || (session == null && legacySuperuser);
    final role = (session?.role ?? roleStr ?? 'employee').toLowerCase();

    await _routeToShell(
      session: session,
      legacySuperuser: isSuperuser && session == null,
      role: role,
      activeDashboardRaw: activeDashboardRaw,
      lastShellRoute: lastShellRoute,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
