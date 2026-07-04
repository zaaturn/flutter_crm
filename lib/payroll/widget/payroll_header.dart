import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/admin_dashboard/shared/admin_dashboard_theme.dart';

import '../../admin_dashboard/screen/device_specific/admin_dashboard_desktop.dart';
import '../../admin_dashboard/screen/device_specific/mobile_screen/mainscreen/admin_dashboard_mobile.dart';

class WorkspaceTheme {
  static const Color primaryPurple = AdminDashboardTheme.teal;
  static const Color cardSurface = AdminDashboardTheme.surface;
  static const Color borderSubtle = AdminDashboardTheme.borderSoft;
  static const Color textMain = AdminDashboardTheme.textDark;
  static const Color textMuted = AdminDashboardTheme.textMuted;
}

class PayrollHeader extends StatelessWidget {
  const PayrollHeader({super.key, this.showTitle = true});

  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: WorkspaceTheme.cardSurface,
        border: Border(
          bottom: BorderSide(color: WorkspaceTheme.borderSubtle, width: 1),
        ),
      ),
      child: Row(
        children: [

          _HeaderActionIcon(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
                return;
              }
              final narrow = MediaQuery.sizeOf(context).width < 900;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(
                  builder: (_) => narrow
                      ? const AdminDashboardMobile()
                      : const AdminDashboardDesktop(),
                ),
              );
            },
          ),
          const SizedBox(width: 20),


          if (showTitle)
            Text(
              'Payroll Overview',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: WorkspaceTheme.textMain,
                letterSpacing: -0.5,
              ),
            ),
        ],
      ),
    );
  }
}

class _HeaderActionIcon extends StatelessWidget {
  const _HeaderActionIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: WorkspaceTheme.borderSubtle),
          ),
          child: Icon(
            icon,
            size: 18,
            color: WorkspaceTheme.textMain,
          ),
        ),
      ),
    );
  }
}