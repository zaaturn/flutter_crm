import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Ensure this path matches your project structure
import '../../admin_dashboard/screen/device_specific/admin_dashboard_desktop.dart';

class WorkspaceTheme {
  static const Color primaryPurple = Color(0xFF6F34DC);
  static const Color cardSurface = Colors.white;
  static const Color borderSubtle = Color(0xFFE8E9F1);
  static const Color textMain = Color(0xFF1E1E24);
  static const Color textMuted = Color(0xFF64748B);
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
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const AdminDashboardDesktop(),
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