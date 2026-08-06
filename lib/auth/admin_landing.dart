import 'package:my_app/admin_dashboard/sidebar/device_specific/sidebar_menu_config_desktop.dart';
import 'package:my_app/auth/auth_session.dart';

/// Preferred landing order when a managed admin has limited modules.
const kAdminModuleLandingOrder = <(String moduleKey, SidebarAction action)>[
  ('asset_management', SidebarAction.assets),
  ('clients', SidebarAction.client),
  ('share', SidebarAction.share),
  ('tasks', SidebarAction.trackTasks),
  ('leave_management', SidebarAction.leaveManagement),
  ('billing', SidebarAction.billingGenerate),
  ('payroll', SidebarAction.payroll),
  ('events', SidebarAction.events),
  ('leads', SidebarAction.leads),
  ('employees', SidebarAction.employees),
  ('analytics', SidebarAction.analytics),
];

extension AuthSessionAdminLanding on AuthSession {
  /// True when this admin has at least one module explicitly turned off.
  bool get hasRestrictedAdminModules {
    if (isSuperuser || !isAdmin) return false;
    if (adminModules.isEmpty) return false;
    return adminModules.values.any((enabled) => enabled == false);
  }

  /// Live attendance / employee login board — hidden for managed admins
  /// without the employees module.
  bool get canSeeAdminHomeLiveBoard {
    if (isSuperuser) return true;
    if (!isAdmin) return false;
    if (!hasRestrictedAdminModules) return true;
    return moduleAllowed('employees');
  }

  bool _actionAllowed(String key) {
    if (key == 'payroll') return canAccessPayrollAdmin;
    if (key == 'analytics') {
      return isSuperuser || adminModules['analytics'] == true;
    }
    return moduleAllowed(key);
  }

  /// First assigned module to open after login / workspace switch.
  /// Only set when modules are restricted (managed user).
  SidebarAction? get firstAssignedSidebarAction {
    if (!hasRestrictedAdminModules) return null;
    for (final entry in kAdminModuleLandingOrder) {
      if (_actionAllowed(entry.$1)) return entry.$2;
    }
    return null;
  }
}

/// One-shot intent consumed by [AdminDashboardDesktop] / mobile after shell push.
class AdminLandingIntent {
  AdminLandingIntent._();

  static SidebarAction? pendingAction;

  static void setPending(SidebarAction? action) {
    pendingAction = action;
  }

  static SidebarAction? takePending() {
    final action = pendingAction;
    pendingAction = null;
    return action;
  }
}
