import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ══════════════════════════════════════════════
// COLOR PALETTE
// ══════════════════════════════════════════════
class AppColors {
  static const primary       = Color(0xFF1A73E8);
  static const primaryLight  = Color(0xFFE8F0FE);
  static const primaryDark   = Color(0xFF1557B0);
  static const accent        = Color(0xFF34A853);
  static const accentLight   = Color(0xFFE6F4EA);
  static const warn          = Color(0xFFFBBC04);
  static const warnLight     = Color(0xFFFEF9E7);
  static const danger        = Color(0xFFEA4335);
  static const dangerLight   = Color(0xFFFCE8E6);
  static const sidebar       = Color(0xFF1E2A38);
  static const sidebarHover  = Color(0xFF2D3F55);
  static const sidebarActive = Color(0xFF243447);
  static const bg            = Color(0xFFF0F4F8);
  static const surface       = Color(0xFFFFFFFF);
  static const border        = Color(0xFFE2E8F0);
  static const text          = Color(0xFF1A202C);
  static const textMuted     = Color(0xFF718096);
  static const textLight     = Color(0xFFA0AEC0);
  static const tableHead     = Color(0xFFF7F9FC);
}

// ══════════════════════════════════════════════
// TEXT STYLES  (Plus Jakarta Sans + DM Mono)
// ══════════════════════════════════════════════
class AppTextStyles {
  static TextStyle get display    => GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.text, letterSpacing: -.4);
  static TextStyle get heading    => GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text, letterSpacing: -.2);
  static TextStyle get subheading => GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text);
  static TextStyle get body       => GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w400, color: AppColors.text);
  static TextStyle get bodyMed    => GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.text);
  static TextStyle get small      => GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textMuted);
  static TextStyle get label      => GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.text);
  static TextStyle get tableHdr   => GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: .6);
  static TextStyle get mono       => GoogleFonts.dmMono(fontSize: 12.5, color: AppColors.text);
}

// ══════════════════════════════════════════════
// THEME
// ══════════════════════════════════════════════
class AppTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    textTheme: GoogleFonts.plusJakartaSansTextTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surface,
      elevation: 0,
      foregroundColor: AppColors.text,
      titleTextStyle: AppTextStyles.subheading,
    ),
  );
}

// ══════════════════════════════════════════════
// GLOBAL RADIUS CONSTANTS
// ══════════════════════════════════════════════
const double kRadius   = 12.0;
const double kRadiusSm = 8.0;
const double kRadiusXs = 6.0;