import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class BillingTheme {
  static const Color purple = Color(0xFF2F7D6D);
  static const Color purpleDark = Color(0xFF1F5F52);
  static const Color purpleLight = Color(0xFFE3F2EE);
  static const Color border = Color(0xFFE3EAE6);
  static const Color textPrimary = Color(0xFF1C2B26);
  static const Color textMuted = Color(0xFF6B7F78);

  /// Full-page canvas — matches the main admin dashboard's mint shell.
  static const Color canvas = Color(0xFFD0E3D8);
  /// Muted secondary-surface tint (inputs, hover states) — not the page bg.
  static const Color scaffoldBg = Color(0xFFF4F7F5);
  static const Color surface = Colors.white;

  static ThemeData datePickerTheme(BuildContext context) {
    final base = Theme.of(context);
    return base.copyWith(
      colorScheme: ColorScheme.light(
        primary: purple,
        onPrimary: Colors.white,
        surface: surface,
        onSurface: textPrimary,
      ),
    );
  }

  static TextStyle titleLarge() => GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w900,
        color: textPrimary,
        letterSpacing: -0.4,
      );

  static TextStyle titleAppBar() => GoogleFonts.plusJakartaSans(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: textPrimary,
      );

  static TextStyle overline() => GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: textMuted,
        letterSpacing: 1.2,
      );

  static TextStyle body() => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textMuted,
        height: 1.45,
      );

  static TextStyle cardTitle() => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: textPrimary,
      );

  static TextStyle cardSubtitle() => GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: textMuted,
        height: 1.4,
      );

  static BoxDecoration cardDecoration({bool highlighted = false}) {
    return BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: highlighted ? purple.withValues(alpha: 0.45) : border,
        width: highlighted ? 1.5 : 1,
      ),
      boxShadow: [
        BoxShadow(
          color: purple.withValues(alpha: 0.06),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
}
