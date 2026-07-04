import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ══════════════════════════════════════════════
// DAXARROW BRAND COLOR PALETTE
// ══════════════════════════════════════════════
class AppColors {
  // Brand Core — matches the mint/teal admin dashboard shell
  static const primary       = Color(0xFF2F7D6D); // Teal
  static const primaryLight  = Color(0xFFE3F2EE); // Teal Tint
  static const primaryDark   = Color(0xFF1F5F52); // Deep Teal

  // Status Colors
  static const accent        = Color(0xFF10B981); // Success Green
  static const accentLight   = Color(0xFFECFDF5);
  static const warn          = Color(0xFFF59E0B); // Amber
  static const warnLight     = Color(0xFFFFFBEB);
  static const danger        = Color(0xFFEF4444); // Red
  static const dangerLight   = Color(0xFFFEF2F2);

  // Sidebar — kept for backward compatibility; the actual rail in
  // app_shell.dart now mirrors the main dashboard's icon rail directly.
  static const sidebar       = Color(0xFF000000);
  static const sidebarHover  = Color(0xFF1A1A1A);
  static const sidebarActive = Color(0xFF1A1A1A);

  // Surfaces & Backgrounds
  static const canvas        = Color(0xFFD0E3D8); // Mint shell canvas
  static const bg            = Color(0xFFF4F7F5); // Muted surface tint (inputs, hover)
  static const surface       = Color(0xFFFFFFFF); // Card Surface
  static const border        = Color(0xFFE3EAE6); // Border
  static const tableHead     = Color(0xFFF4F7F5);

  // Neutral Text
  static const text          = Color(0xFF1C2B26); // Dark Slate
  static const textMuted     = Color(0xFF6B7F78); // Muted Slate
  static const textLight     = Color(0xFF9AABA3); // Light Muted
}

// ══════════════════════════════════════════════
// DAXARROW TEXT STYLES (Plus Jakarta Sans)
// ══════════════════════════════════════════════
class AppTextStyles {
  static TextStyle get display    => GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.text, letterSpacing: -.8);
  static TextStyle get heading    => GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.text, letterSpacing: -.5);
  static TextStyle get subheading => GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text);
  static TextStyle get body       => GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w500, color: AppColors.text, height: 1.5);
  static TextStyle get bodyMed    => GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.text);
  static TextStyle get small      => GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted);
  static TextStyle get label      => GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.text);
  static TextStyle get tableHdr   => GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textLight, letterSpacing: 1.2);
  static TextStyle get mono       => GoogleFonts.dmMono(fontSize: 12.5, fontWeight: FontWeight.w500, color: AppColors.text);
}

// ══════════════════════════════════════════════
// THEME CONFIGURATION
// ══════════════════════════════════════════════
class AppTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.canvas,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: AppColors.surface,
    ),
    textTheme: GoogleFonts.plusJakartaSansTextTheme(),


    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: AppColors.text,
      titleTextStyle: AppTextStyles.subheading,
      iconTheme: const IconThemeData(color: AppColors.text, size: 20),
    ),


    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadius),
        side: const BorderSide(color: AppColors.border, width: 1.5),
      ),
    ),


    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kRadiusSm),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kRadiusSm),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kRadiusSm),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    ),


    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusSm)),
        textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 14),
      ),
    ),
  );
}

// ══════════════════════════════════════════════
// GLOBAL RADIUS CONSTANTS
// ══════════════════════════════════════════════
const double kRadius   = 20.0;
const double kRadiusMd = 12.0;
const double kRadiusSm = 8.0;
const double kRadiusXs = 6.0;

const double kBorderWidth = 1.5;