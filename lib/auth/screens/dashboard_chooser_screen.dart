import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:my_app/auth/auth_navigation.dart';
import 'package:my_app/auth/auth_session.dart';
import 'package:my_app/services/auth_service.dart';

class DashboardChooserScreen extends StatelessWidget {
  const DashboardChooserScreen({super.key});

  static const _purple      = Color(0xFF7C3AED);
  static const _purpleLight = Color(0xFFF5F3FF);
  static const _textPrimary = Color(0xFF0F172A);
  static const _textMuted   = Color(0xFF64748B);
  static const _border      = Color(0xFFEDE9FE);
  static const _bg          = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // Subtle background decorative element
          Positioned(
            top: -100,
            right: -100,
            child: CircleAvatar(
              radius: 200,
              backgroundColor: _purpleLight.withOpacity(0.5),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Logo / Icon
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _purpleLight,
                          shape: BoxShape.circle,
                          border: Border.all(color: _border, width: 2),
                        ),
                        child: const Icon(Icons.bolt_rounded, color: _purple, size: 40),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Choose Workspace',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: _textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Select the dashboard you want to access.\nYou can switch between them later.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        color: _textMuted,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Options
                    _BigChoice(
                      title: 'Employee Dashboard',
                      icon: Icons.person_outline_rounded,
                      onTap: () async {
                        await AuthService().setActiveDashboard(ActiveDashboard.employee);
                        if (!context.mounted) return;
                        await AuthNavigation.openEmployeeShell(context);
                      },
                    ),
                    const SizedBox(height: 16),
                    _BigChoice(
                      title: 'Admin Dashboard',
                      icon: Icons.admin_panel_settings_outlined,
                      onTap: () async {
                        await AuthService().setActiveDashboard(ActiveDashboard.admin);
                        if (!context.mounted) return;
                        await AuthNavigation.openAdminShell(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BigChoice extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _BigChoice({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const purple      = Color(0xFF7C3AED);
    const purpleLight = Color(0xFFF5F3FF);
    const textPrimary = Color(0xFF0F172A);
    const border      = Color(0xFFEDE9FE);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: purple.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: purpleLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: purple, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: purple, size: 16),
          ],
        ),
      ),
    );
  }
}