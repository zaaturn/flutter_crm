import 'package:flutter/material.dart';

import 'package:my_app/admin_dashboard/screen/device_specific/admin_dashboard_desktop.dart';
import 'package:my_app/auth/screens/superadmin_users_screen.dart';
import 'package:my_app/auth/auth_session.dart';
import 'package:my_app/auth/screens/dashboard_chooser_screen.dart';
import 'package:my_app/core/layout/adaptive_layout.dart';
import 'package:my_app/employee_dashboard/screen/employee_dashboard_screen.dart';
import 'package:my_app/employee_dashboard/screen/employee_dashboard_screen_desktop.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/mainscreen/admin_dashboard_mobile.dart';
import 'package:my_app/services/auth_service.dart';

/// Central post-login and shell switching (employee / admin / superadmin).
class AuthNavigation {
  AuthNavigation._();

  static Future<void> navigateAfterLogin(
    BuildContext context,
    Map<String, dynamic> loginResponse,
  ) async {
    final session = AuthSession.fromJson(loginResponse);
    final auth = AuthService();

    if (session.isSuperuser) {
      await auth.setActiveDashboard(ActiveDashboard.admin);
      if (!context.mounted) return;
      await _pushDashboardForAdmin(context, ActiveDashboard.admin);
      return;
    }

    if (session.isAdmin) {
      final existing = await auth.readActiveDashboard();
      if (existing == null) {
        if (!context.mounted) return;
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const DashboardChooserScreen()),
          (_) => false,
        );
        return;
      }
      if (!context.mounted) return;
      await _pushDashboardForAdmin(context, existing);
      return;
    }

    // employee, client, or unknown → employee shell
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const AdaptiveLayout(
          mobile: EmployeeDashboardScreen(),
          tablet: EmployeeDashboardScreen(),
          webDesktop: EmployeeDashboardDesktop(),
        ),
      ),
      (_) => false,
    );
  }

  static Future<void> _pushDashboardForAdmin(
    BuildContext context,
    ActiveDashboard dash,
  ) async {
    if (!context.mounted) return;
    if (dash == ActiveDashboard.admin) {
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const AdaptiveLayout(
            mobile: AdminDashboardMobile(),
            tablet: AdminDashboardMobile(),
            webDesktop: AdminDashboardDesktop(),
          ),
        ),
        (_) => false,
      );
    } else {
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const AdaptiveLayout(
            mobile: EmployeeDashboardScreen(),
            tablet: EmployeeDashboardScreen(),
            webDesktop: EmployeeDashboardDesktop(),
          ),
        ),
        (_) => false,
      );
    }
  }

  static Future<void> openAdminShell(BuildContext context) async {
    await AuthService().setActiveDashboard(ActiveDashboard.admin);
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const AdaptiveLayout(
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
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const AdaptiveLayout(
          mobile: EmployeeDashboardScreen(),
          tablet: EmployeeDashboardScreen(),
          webDesktop: EmployeeDashboardDesktop(),
        ),
      ),
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
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => const DashboardChooserScreen()),
    );
  }
}
