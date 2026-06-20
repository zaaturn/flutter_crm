import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Matches admin [DesktopSidebar] palette and typography.
abstract final class DashboardSidebarTheme {
  static const Color background = Colors.white;
  static const Color purple = Color(0xFF7C3AED);
  static const Color purpleLight = Color(0xFFF5F3FF);
  static const Color purpleDark = Color(0xFF4C1D95);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF334155);
  static const Color border = Color(0xFFEDE9FE);
  static const Color red = Color(0xFFEF4444);
  static const Color green = Color(0xFF10B981);

  static const double width = 280;

  static TextStyle brandWordmark() => GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w900,
        color: textPrimary,
        letterSpacing: 0.5,
      );

  static TextStyle sectionOverline() => GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: textMuted.withValues(alpha: 0.7),
        letterSpacing: 1.5,
      );

  static TextStyle navItem({required bool active}) => GoogleFonts.plusJakartaSans(
        fontWeight: active ? FontWeight.w900 : FontWeight.w800,
        fontSize: 14,
        color: active ? purpleDark : textPrimary,
      );

  static TextStyle userName() => GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w900,
        color: textPrimary,
        fontSize: 13,
      );

  static TextStyle userMeta() => GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: green,
      );

  static TextStyle dialogTitle() => GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: textPrimary,
      );

  static TextStyle dialogBody() => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textMuted,
      );

  static TextStyle sheetRowTitle() => GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w700,
        fontSize: 14,
        color: textPrimary,
      );

  static TextStyle sheetRowSubtitle() => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textMuted,
      );
}
