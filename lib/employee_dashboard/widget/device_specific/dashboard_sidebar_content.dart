import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/auth/auth_navigation.dart';
import 'package:my_app/employee_dashboard/navigation/employee_dashboard_navigation.dart';

// Assuming your theme file is updated to these constants
class WorkspaceTheme {
  static const Color primaryPurple = Color(0xFF6F34DC);
  static const Color cardSurface = Colors.white;
  static const Color borderSubtle = Color(0xFFE8E9F1);
  static const Color textMain = Color(0xFF1E1E24);
  static const Color textMuted = Color(0xFF64748B);
  static const Color danger = Color(0xFFEF4444);
  static const Color activeBg = Color(0x0D6F34DC);
}

class DashboardSidebarContent {
  DashboardSidebarContent._();

  static Widget header({required VoidCallback onOpenWorkspaceMenu}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 56, 16, 20),
      child: GestureDetector(
        onTap: onOpenWorkspaceMenu,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.black,
                  width: 2.0,
                ),
              ),
              padding: const EdgeInsets.all(4),
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.bolt_rounded,
                  color: Colors.black,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 14),

            Text(
              'DAXARROW',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: 1.0,
                color: WorkspaceTheme.textMain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: WorkspaceTheme.textMuted,
        ),
      ),
    );
  }

  static Widget navTile({
    required String label,
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: active ? WorkspaceTheme.activeBg : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: active ? WorkspaceTheme.primaryPurple : WorkspaceTheme.textMuted,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active ? WorkspaceTheme.primaryPurple : WorkspaceTheme.textMain,
                  ),
                ),
              ),
              if (active)
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: WorkspaceTheme.primaryPurple,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget userCard({
    required String name,
    required String initials,
    required VoidCallback onLogoutTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WorkspaceTheme.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: WorkspaceTheme.primaryPurple,
            child: Text(
              initials,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: WorkspaceTheme.textMain,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Active Now',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onLogoutTap,
            icon: const Icon(Icons.logout_rounded, size: 18, color: WorkspaceTheme.danger),
            visualDensity: VisualDensity.compact,
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
                  const Icon(Icons.error_outline_rounded, color: WorkspaceTheme.danger, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Sign Out',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: WorkspaceTheme.textMain,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Are you sure you want to exit your workspace?',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(color: WorkspaceTheme.textMuted, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text('Cancel', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: WorkspaceTheme.textMuted)),
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
                            backgroundColor: WorkspaceTheme.danger,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text('Exit', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
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
                    color: WorkspaceTheme.borderSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
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
          border: Border.all(color: WorkspaceTheme.borderSubtle),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: WorkspaceTheme.activeBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: WorkspaceTheme.primaryPurple, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: WorkspaceTheme.textMain,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: WorkspaceTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: WorkspaceTheme.textMuted),
          ],
        ),
      ),
    );
  }
}