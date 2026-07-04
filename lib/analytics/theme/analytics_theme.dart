import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Desktop analytics — matches the main admin dashboard's mint shell / teal
/// accent / white panel language so Analytics doesn't feel like a different
/// app once you navigate into it.
abstract final class AnalyticsDesktopTheme {
  static const double sidebarWidth = 88;
  static const double cardRadius = 20;
  static const double controlRadius = 12;

  static const Color scaffoldBg = Color(0xFFD0E3D8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF4F7F5);
  static const Color iconRailBg = Color(0xFFF0F4F2);

  /// Dashboard brand teal (sidebar selected state) — was purple; renamed
  /// call sites keep `purple*` names to avoid touching every widget.
  static const Color purple = Color(0xFF2F7D6D);
  static const Color purpleDark = Color(0xFF1F5F52);
  static const Color purpleLight = Color(0xFFE3F2EE);
  static const Color purpleBorder = Color(0xFFD7E8E2);

  /// Selected sidebar-icon fill — matches the main dashboard's rail accent.
  static const Color accentYellow = Color(0xFFF5C842);

  static const Color textMain = Color(0xFF1C2B26);
  static const Color textMuted = Color(0xFF6B7F78);
  static const Color labelMuted = Color(0xFF9AABA3);
  static const Color border = Color(0xFFE3EAE6);
  static const Color tableHeader = Color(0xFFF4F7F5);
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
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 12,
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

/// Mobile analytics — warm terracotta shell (separate from desktop purple).
abstract final class AnalyticsMobileTheme {
  static const Color background = Color(0xFFF0DDD3);
  static const Color terracotta = Color(0xFFC05E41);
  static const Color terracottaDark = Color(0xFF9E4A33);
  static const Color card = Color(0xFFFFF8F4);
  static const Color field = Color(0xFFEADBC8);
  static const Color border = Color(0xFFE8C4B4);
  static const Color textDark = Color(0xFF3D2318);
  static const Color textMuted = Color(0xFF8B6B5C);
}

/// Earth-tone palette for overview / business KPI tiles.
abstract final class AnalyticsOverviewPalette {
  static const Color mutedTeal = Color(0xFF5D8F8C);
  static const Color softMauve = Color(0xFFB08AA3);
  static const Color sageGreen = Color(0xFFA4B494);
  static const Color warmBeige = Color(0xFFDCC8B0);
  static const Color deepBrown = Color(0xFF5B3A30);
  static const Color slateBlue = Color(0xFF6B8CAE);
  static const Color berry = Color(0xFF9E4A63);
  static const Color mustard = Color(0xFFC9A84C);
  static const Color charcoal = Color(0xFF4A4A48);
  static const Color terracotta = Color(0xFFC4704A);

  static Color labelOn(Color bg) =>
      ThemeData.estimateBrightnessForColor(bg) == Brightness.dark
          ? Colors.white.withValues(alpha: 0.92)
          : const Color(0xFF3D3229);

  static Color valueOn(Color bg) =>
      ThemeData.estimateBrightnessForColor(bg) == Brightness.dark
          ? Colors.white
          : const Color(0xFF1F1814);
}
