import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      surface: AppColors.card,
      onSurface: AppColors.textPrimary,
      outline: AppColors.border,
      error: AppColors.danger,
    ),

    textTheme: _baseTextTheme,


    cardTheme: CardThemeData(
      color: AppColors.card,
      surfaceTintColor: Colors.transparent,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
    ),

    scaffoldBackgroundColor: AppColors.background,

    // ── Buttons ──
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        textStyle:
        const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        elevation: 3,
        shadowColor: AppColors.primary.withValues(alpha: 0.35),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.border, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding:
        const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        textStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    // ── Input ──
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFFAFBFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:
        const BorderSide(color: AppColors.border, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:
        const BorderSide(color: AppColors.border, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:
        BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:
        const BorderSide(color: AppColors.danger, width: 1.5),
      ),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      labelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
      ),
    ),

    dividerColor: AppColors.border,
    dividerTheme:
    const DividerThemeData(space: 16, thickness: 1),
  );

  // ── Dark ──
  static ThemeData get dark => light.copyWith(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121420),
    colorScheme: light.colorScheme.copyWith(
      brightness: Brightness.dark,
      surface: const Color(0xFF1A1D2E),
      onSurface: Colors.white,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1A1D2E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFF2E3147), width: 1),
      ),
    ),
  );

  // ── TextTheme ──
  static const TextTheme _baseTextTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
    displayMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
    displaySmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    headlineMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    headlineSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
    titleSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
    labelMedium: TextStyle(
        fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.6),
    labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
  );
}
