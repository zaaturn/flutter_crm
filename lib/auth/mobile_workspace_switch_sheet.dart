import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:my_app/auth/auth_navigation.dart';
import 'package:my_app/leave_management/screens/mobile_screen/widget/leave_manager_colors.dart';

/// Mobile-only bottom sheet: same navigation as [WorkspaceSwitcherSheet]
/// (employee vs admin shells), styled with Leave Management indigo.
///
/// Uses [AuthNavigation.openEmployeeShell] / [openAdminShell] so each shell
/// replaces the stack — no admin/employee UI mixing in one route.
class MobileWorkspaceSwitchSheet {
  static void show(BuildContext parentContext) {
    showModalBottomSheet<void>(
      context: parentContext,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: LeaveManagerColors.outline.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Text(
                'Choose workspace',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: LeaveManagerColors.onBackground,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Switches your full session view. Same as desktop.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: LeaveManagerColors.outline,
                ),
              ),
              const SizedBox(height: 16),
              _option(
                ctx,
                parentContext,
                icon: Icons.person_outline_rounded,
                title: 'Employee workspace',
                subtitle: 'Tasks, attendance, and your profile',
                onChosen: AuthNavigation.openEmployeeShell,
              ),
              _option(
                ctx,
                parentContext,
                icon: Icons.admin_panel_settings_outlined,
                title: 'Admin dashboard',
                subtitle: 'Operations and team tools',
                onChosen: AuthNavigation.openAdminShell,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _option(
    BuildContext sheetContext,
    BuildContext parentContext, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Future<void> Function(BuildContext context) onChosen,
  }) {
    return ListTile(
      onTap: () async {
        Navigator.pop(sheetContext);
        await onChosen(parentContext);
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF3FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: LeaveManagerColors.primary, size: 24),
      ),
      title: Text(
        title,
        style: GoogleFonts.manrope(
          fontWeight: FontWeight.w800,
          color: LeaveManagerColors.onBackground,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          color: LeaveManagerColors.outline,
          fontSize: 12,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: LeaveManagerColors.outline.withValues(alpha: 0.5),
      ),
    );
  }
}
