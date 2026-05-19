import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class BillingTheme {
  static const Color purple = Color(0xFF7C3AED);
  static const Color purpleDark = Color(0xFF4C1D95);
  static const Color purpleLight = Color(0xFFF5F3FF);
  static const Color border = Color(0xFFEDE9FE);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color scaffoldBg = Color(0xFFF8FAFC);
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
