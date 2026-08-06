import 'package:flutter/material.dart';

import 'package:my_app/admin_dashboard/screen/device_specific/admin_dashboard_desktop.dart';
import 'package:my_app/auth/screens/superadmin_users_screen.dart';
import 'package:my_app/auth/admin_landing.dart';
import 'package:my_app/auth/auth_session.dart';
import 'package:my_app/auth/screens/dashboard_chooser_screen.dart';
import 'package:my_app/core/layout/adaptive_layout.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/mainscreen/admin_dashboard_mobile.dart';
import 'package:my_app/core/auth/admin_access_guard.dart';
import 'package:my_app/core/auth/shell_route_persistence.dart';
import 'package:my_app/services/auth_service.dart';
import 'package:my_app/services/secure_storage_service.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/widgets/admin_dashboard_widgets/aniamtion_welcome.dart';

/// Central post-login and shell switching (employee / admin / superadmin).
class AuthNavigation {
  AuthNavigation._();

  static Future<void> _prepareAdminLanding(AuthSession session) async {
    if (session.hasRestrictedAdminModules) {
      AdminLandingIntent.setPending(session.firstAssignedSidebarAction);
    } else {
      AdminLandingIntent.setPending(null);
    }
  }

  static Future<AuthSession?> _readSession() async {
    final raw = await SecureStorageService().readAuthSessionJson();
    return AuthSession.fromStorageString(raw);
  }

  static Future<void> navigateAfterLogin(
    BuildContext context,
    Map<String, dynamic> loginResponse,
  ) async {
    final session = AuthSession.fromJson(loginResponse);
    final auth = AuthService();

    if (session.isSuperuser) {
      await auth.setActiveDashboard(ActiveDashboard.admin);
      if (!context.mounted) return;
      await _pushDashboardForAdmin(context, ActiveDashboard.admin, loginResponse);
      return;
    }

    if (session.isAdmin) {
      final existing = await auth.readActiveDashboard();
      if (existing == null) {
        await auth.setActiveDashboard(ActiveDashboard.admin);
        if (!context.mounted) return;
        await _pushDashboardForAdmin(context, ActiveDashboard.admin, loginResponse);
        return;
      }
      if (!context.mounted) return;
      await _pushDashboardForAdmin(context, existing, loginResponse);
      return;
    }

    await ShellRoutePersistence.markEmployeeShell();
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
      '/employeeDashboard',
      (_) => false,
    );
  }

  static Future<void> _pushDashboardForAdmin(
    BuildContext context,
    ActiveDashboard dash,
    Map<String, dynamic> loginResponse,
  ) async {
    final session = AuthSession.fromJson(loginResponse);
    if (!context.mounted) return;
    if (dash == ActiveDashboard.admin) {
      if (!session.canAccessAdminDashboard) {
        await ShellRoutePersistence.markEmployeeShell();
        if (!context.mounted) return;
        Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
          '/employeeDashboard',
          (_) => false,
        );
        return;
      }

      await _prepareAdminLanding(session);

      final String? displayName = () {
        try {
          final user = loginResponse['user'];
          if (user is Map) {
            final first =
                (user['first_name'] ?? user['firstName'] ?? '').toString().trim();
            final last =
                (user['last_name'] ?? user['lastName'] ?? '').toString().trim();
            final full = ('$first $last').trim();
            if (full.isNotEmpty) return full;
          }
        } catch (_) {}
        return null;
      }();

      final skipWelcome = session.hasRestrictedAdminModules;

      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(
          settings: const RouteSettings(name: '/adminDashboard'),
          builder: (routeCtx) {
            return AdaptiveLayout(
              mobile: skipWelcome
                  ? AdminDashboardMobile()
                  : AdminWelcomeScreen(
                      displayName: displayName,
                      onDone: () {
                        Navigator.of(routeCtx, rootNavigator: true)
                            .pushNamedAndRemoveUntil(
                          '/adminDashboard',
                          (_) => false,
                        );
                      },
                    ),
              tablet: AdminDashboardMobile(),
              webDesktop: AdminDashboardDesktop(),
            );
          },
        ),
        (_) => false,
      );
    } else {
      await ShellRoutePersistence.markEmployeeShell();
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
        '/employeeDashboard',
        (_) => false,
      );
    }
  }

  static Future<void> openAdminShell(BuildContext context) async {
    if (!await AdminAccessGuard.ensureAccess(context)) return;
    final session = await _readSession();
    if (session != null) await _prepareAdminLanding(session);
    await AuthService().setActiveDashboard(ActiveDashboard.admin);
    await ShellRoutePersistence.markAdminShell();
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/adminDashboard'),
        builder: (routeCtx) => AdaptiveLayout(
          mobile: AdminDashboardMobile(),
          tablet: AdminDashboardMobile(),
          webDesktop: AdminDashboardDesktop(),
        ),
      ),
      (_) => false,
    );
  }

  static Future<void> openEmployeeShell(BuildContext context) async {
    await AuthService().setActiveDashboard(ActiveDashboard.employee);
    await ShellRoutePersistence.markEmployeeShell();
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
      '/employeeDashboard',
      (_) => false,
    );
  }

  static Future<void> openSuperadmin(BuildContext context) async {
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => const SuperadminUsersScreen()),
    );
  }

  static Future<void> openDashboardChooser(BuildContext context) async {
    if (!await AdminAccessGuard.ensureAccess(context)) return;
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => const DashboardChooserScreen()),
    );
  }
}
