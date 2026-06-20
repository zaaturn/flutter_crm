import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_app/auth/auth_session.dart';
import 'package:my_app/auth/profile_remote_sync.dart';
import 'package:my_app/core/auth/jwt_utils.dart';
import 'package:my_app/services/auth_service.dart';
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
    try {
      await AuthService().logout();
    } catch (_) {
      await SecureStorageService().clearAll();
      ApiClient().forceUnauthenticated();
    }
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
      '/employeeLogin',
      (route) => false,
    );
  }

  Future<void> _checkAuth() async {
    final storage = SecureStorageService();

    String? token;
    String? activeDashboardRaw;

    try {
      token = await storage.readToken().timeout(_storageTimeout);
      activeDashboardRaw = await storage.readActiveDashboard().timeout(_storageTimeout);
    } on TimeoutException {
      token = null;
      activeDashboardRaw = null;
    } catch (_) {
      token = null;
      activeDashboardRaw = null;
    }

    final accessExpired =
        token != null && token.isNotEmpty && JwtUtils.isExpired(token);

    if (token == null || token.isEmpty || accessExpired) {
      final refresh = await storage.readRefreshToken().timeout(_storageTimeout);
      if (refresh != null && refresh.isNotEmpty) {
        try {
          final ok = await ApiClient().ensureSessionValid(redirectOnFailure: true);
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

    if (isSuperuser) {
      await AuthService().setActiveDashboard(ActiveDashboard.admin);
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
        '/adminDashboard',
        (route) => false,
      );
      return;
    }

    if (role == 'admin') {
      final active = ActiveDashboardStorage.fromString(activeDashboardRaw);
      if (active == null) {
        Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
          '/dashboardChooser',
          (route) => false,
        );
        return;
      }
      if (active == ActiveDashboard.admin) {
        Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
          '/adminDashboard',
          (route) => false,
        );
      } else {
        Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
          '/employeeDashboard',
          (route) => false,
        );
      }
      return;
    }

    Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
      '/employeeDashboard',
      (route) => false,
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