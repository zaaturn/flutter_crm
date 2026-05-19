import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colors and typography for [DashboardSidebar] (white shell, darker text,
/// purple accent — notification-badge style).
abstract final class DashboardSidebarTheme {
  static const Color background = Color(0xFFFFFFFF);
  static const Color sheetBackground = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF1F5F9);
  static const Color border = Color(0xFFE2E8F0);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF475569);
  static const Color accent = Color(0xFF6366F1);
  static const Color accentDark = Color(0xFF4F46E5);
  static const Color accentLight = Color(0xFFEEF2FF);
  static const Color danger = Color(0xFFDC2626);
  static const Color online = Color(0xFF059669);

  static TextStyle brandWordmark() => GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: textPrimary,
        letterSpacing: 0.2,
        height: 1.2,
      );

  static TextStyle sectionOverline() => GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: textMuted,
        letterSpacing: 1.4,
        height: 1.2,
      );

  static TextStyle navItem({required bool active}) => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: active ? FontWeight.w700 : FontWeight.w600,
        color: active ? accentDark : textSecondary,
        height: 1.25,
      );

  static TextStyle userName() => GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1.2,
      );

  static TextStyle userMeta() => GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: textMuted,
        height: 1.2,
      );

  static TextStyle dialogTitle() => GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: textPrimary,
        height: 1.2,
      );

  static TextStyle dialogBody() => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textMuted,
        height: 1.45,
      );

  static TextStyle sheetRowTitle() => GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.25,
      );

  static TextStyle sheetRowSubtitle() => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textMuted,
        height: 1.3,
      );

  static BoxDecoration badgeDecoration() => const BoxDecoration(
        color: accent,
        shape: BoxShape.circle,
      );
}
