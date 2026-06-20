import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Analytics tokens — matches admin dashboard purple (#7C3AED).
abstract final class AnalyticsDesktopTheme {
  static const double sidebarWidth = 220;
  static const double cardRadius = 16;
  static const double controlRadius = 12;

  static const Color scaffoldBg = Color(0xFFF5F3FF);
  static const Color surface = Color(0xFFFFFFFF);

  /// Dashboard brand purple (sidebar selected state).
  static const Color purple = Color(0xFF7C3AED);
  static const Color purpleDark = Color(0xFF4C1D95);
  static const Color purpleLight = Color(0xFFF5F3FF);
  static const Color purpleBorder = Color(0xFFDDD6FE);

  static const Color textMain = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color labelMuted = Color(0xFF94A3B8);
  static const Color border = Color(0xFFEDE9FE);
  static const Color tableHeader = Color(0xFFF8FAFC);
  static const Color success = Color(0xFF059669);
  static const Color successBg = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFD97706);
  static const Color warningBg = Color(0xFFFEF3C7);
  static const Color danger = Color(0xFFDC2626);
  static const Color dangerBg = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF2563EB);
  static const Color infoBg = Color(0xFFDBEAFE);
  static const Color neutralBg = Color(0xFFF1F5F9);

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: purple.withValues(alpha: 0.08),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ];

  static TextStyle get titleLg => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: textMain,
        letterSpacing: -0.2,
      );

  static TextStyle get titleMd => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: textMain,
      );

  static TextStyle get bodySm => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: textMuted,
      );

  static TextStyle get tableHeaderStyle => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: labelMuted,
        letterSpacing: 0.6,
      );

  static TextStyle get tableCellStyle => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: textMain,
      );

  static TextStyle get tableCellBold => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: textMain,
      );
}

/// Mobile analytics — same dashboard purple.
abstract final class AnalyticsMobileTheme {
  static const Color background = Color(0xFFF5F3FF);
  static const Color terracotta = Color(0xFF7C3AED);
  static const Color card = Color(0xFFFFFFFF);
  static const Color field = Color(0xFFF5F3FF);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
}
