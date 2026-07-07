import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:my_app/admin_dashboard/sidebar/device_specific/workspace_switcher_desktop.dart';
import 'package:my_app/auth/auth_navigation.dart';
import 'package:my_app/employee_dashboard/navigation/employee_dashboard_navigation.dart';

import 'package:my_app/employee_dashboard/widget/employee_avatar.dart';

import 'dashboard_sidebar_theme.dart';

class DashboardSidebarContent {
  DashboardSidebarContent._();

  static Widget userFooter({
    required BuildContext context,
    required BuildContext parentContext,
    required String name,
    required String initials,
    String? photoUrl,
    required bool canSwitchWorkspace,
    required VoidCallback onLogoutTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 24),
      decoration: BoxDecoration(
        color: DashboardSidebarTheme.purpleLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DashboardSidebarTheme.border, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (canSwitchWorkspace)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: OutlinedButton.icon(
                onPressed: () => WorkspaceSwitcherSheet.show(context, parentContext),
                style: OutlinedButton.styleFrom(
                  foregroundColor: DashboardSidebarTheme.purple,
                  side: const BorderSide(color: DashboardSidebarTheme.purple, width: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                label: Text(
                  'Switch workspace',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          Row(
            children: [
              EmployeeAvatar(
                photoUrl: photoUrl,
                initials: initials,
                size: 36,
                borderRadius: BorderRadius.circular(18),
                backgroundColor: DashboardSidebarTheme.purple,
                foregroundColor: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      style: DashboardSidebarTheme.userName(),
                    ),
                    Text('Active Now', style: DashboardSidebarTheme.userMeta()),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => showLogoutDialog(
                  context: context,
                  onConfirmLogout: onLogoutTap,
                ),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: DashboardSidebarTheme.red.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.power_settings_new_rounded,
                    size: 18,
                    color: DashboardSidebarTheme.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Future<void> showLogoutDialog({
    required BuildContext context,
    required VoidCallback onConfirmLogout,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) => const SizedBox(),
      transitionBuilder: (ctx, anim, _, __) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: anim.drive(CurveTween(curve: Curves.easeOutBack)),
            child: AlertDialog(
              backgroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: DashboardSidebarTheme.red,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text('Sign Out', style: DashboardSidebarTheme.dialogTitle()),
                  const SizedBox(height: 8),
                  Text(
                    'Are you sure you want to exit your workspace?',
                    textAlign: TextAlign.center,
                    style: DashboardSidebarTheme.dialogBody(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w600,
                              color: DashboardSidebarTheme.textMuted,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            onConfirmLogout();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DashboardSidebarTheme.red,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Exit',
                            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> showWorkspaceChooser({
    required BuildContext sidebarContext,
    required bool canOpenAdminWorkspace,
  }) {
    return showModalBottomSheet<void>(
      context: sidebarContext,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: DashboardSidebarTheme.textMuted.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Text(
                  'Choose Workspace',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: DashboardSidebarTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _workspaceRow(
                  sheetCtx: sheetCtx,
                  icon: Icons.person_outline_rounded,
                  title: 'Employee Workspace',
                  subtitle: 'Dashboard, tasks, and leave management',
                  onChosen: () => EmployeeDashboardNavigator.dashboard(sidebarContext),
                ),
                const SizedBox(height: 8),
                if (canOpenAdminWorkspace)
                  _workspaceRow(
                    sheetCtx: sheetCtx,
                    icon: Icons.admin_panel_settings_outlined,
                    title: 'Admin Workspace',
                    subtitle: 'CRM tools and system management',
                    onChosen: () => AuthNavigation.openAdminShell(sidebarContext),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _workspaceRow({
    required BuildContext sheetCtx,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onChosen,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.pop(sheetCtx);
        onChosen();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: DashboardSidebarTheme.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: DashboardSidebarTheme.purpleLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: DashboardSidebarTheme.purple, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: DashboardSidebarTheme.sheetRowTitle()),
                  Text(subtitle, style: DashboardSidebarTheme.sheetRowSubtitle()),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: DashboardSidebarTheme.textMuted),
          ],
        ),
      ),
    );
  }
}
