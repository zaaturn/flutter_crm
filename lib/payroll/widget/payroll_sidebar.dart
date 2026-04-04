import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/payroll_colors.dart';

class PayrollSidebar extends StatelessWidget {
  const PayrollSidebar({super.key});

  static const _bg          = Color(0xFF000000); // Pure Black
  static const _activeBg    = Color(0xFF1A1A1A); // Dark Grey Surface
  static const _textPrimary = Color(0xFFFFFFFF);
  static const _textMuted   = Color(0xFF71717A);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 256,
      decoration: const BoxDecoration(
        color: _bg,
        border: Border(
          right: BorderSide(color: Color(0xFF1A1A1A), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _activeBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.payments, color: PayrollColors.purple, size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payrolls',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: _textPrimary,
                      ),
                    ),
                    Text(
                      'PAYROLL ADMIN',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: _textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                _NavRow(
                  icon: Icons.dashboard_outlined,
                  label: 'Dashboard',
                  active: false,
                ),
                const SizedBox(height: 4),
                _NavRow(
                  icon: Icons.payments_outlined,
                  label: 'Payroll Records',
                  active: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.icon,
    required this.label,
    required this.active,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final bg = active ? const Color(0xFF1A1A1A) : Colors.transparent;
    final fg = active ? Colors.white : const Color(0xFFE4E4E7);
    final iconColor = active ? const Color(0xFFA78BFA) : const Color(0xFFE4E4E7);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 22, color: iconColor),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: active ? FontWeight.w800 : FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}