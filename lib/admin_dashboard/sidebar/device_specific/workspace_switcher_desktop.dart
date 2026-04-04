import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/auth/auth_navigation.dart';

class WorkspaceSwitcherSheet {
  static const _purple      = Color(0xFF7C3AED);
  static const _purpleLight = Color(0xFFF5F3FF);
  static const _textPrimary = Color(0xFF0F172A);
  static const _textMuted   = Color(0xFF334155);

  static void show(BuildContext context, BuildContext parentContext) {
    showModalBottomSheet(
      context: context,
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
                  color: _textMuted.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Text(
                'Choose Workspace',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildOption(
                ctx,
                icon: Icons.person_outline_rounded,
                title: 'Employee Workspace',
                subtitle: 'Manage your tasks and profile',
                onTap: () {
                  Navigator.pop(ctx);
                  AuthNavigation.openEmployeeShell(parentContext);
                },
              ),
              _buildOption(
                ctx,
                icon: Icons.admin_panel_settings_outlined,
                title: 'Admin Dashboard',
                subtitle: 'Full access to system controls',
                onTap: () {
                  Navigator.pop(ctx);
                  AuthNavigation.openAdminShell(parentContext);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildOption(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _purpleLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: _purple, size: 24),
      ),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w800,
          color: _textPrimary,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w600,
          color: _textMuted,
          fontSize: 12,
        ),
      ),
      trailing: Icon(Icons.chevron_right_rounded, color: _textMuted.withOpacity(0.5)),
    );
  }
}