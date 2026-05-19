import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/leave_management/screens/mobile_screen/widget/leave_manager_colors.dart';

/// Admin employee detail (mobile) — tokens aligned with Leave Management mobile.
abstract final class EmployeeDetailMobileTheme {
  static const Color bg = LeaveManagerColors.background;
  static const Color surface = LeaveManagerColors.surface;
  static const Color header = LeaveManagerColors.headerBar;
  static const Color primary = LeaveManagerColors.primary;
  static const Color primaryDark = LeaveManagerColors.primaryDark;
  static const Color text = LeaveManagerColors.onBackground;
  static const Color muted = LeaveManagerColors.outline;
  static const Color border = Color(0xFFE2E8F0);
  static const Color primarySoftSurface = Color(0xFFEFF3FF);

  static BoxDecoration cardDecoration() => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      );

  static TextStyle screenTitle() => GoogleFonts.manrope(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
        color: LeaveManagerColors.brandText,
      );

  static TextStyle sectionTitle() => GoogleFonts.manrope(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: text,
      );

  static TextStyle label() => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: muted,
        height: 1.3,
      );

  static TextStyle value() => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: text,
        height: 1.35,
      );
}
