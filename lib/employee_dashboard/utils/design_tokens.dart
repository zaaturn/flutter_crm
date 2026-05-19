import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Extracted from the Tailwind config provided.
class AppColors {
  static const primary = Color(0xFF4445D1);
  static const primaryContainer = Color(0xFF5E60EB);
  static const primaryFixed = Color(0xFFE1E0FF);
  static const onPrimaryFixedVariant = Color(0xFF2F2EBE);

  static const secondary = Color(0xFF515F74);
  static const secondaryFixed = Color(0xFFD5E3FC);

  static const tertiary = Color(0xFF006645);
  static const tertiaryFixed = Color(0xFF6FFBBE);
  static const onTertiaryFixed = Color(0xFF002113);
  static const onTertiaryFixedVariant = Color(0xFF005236);

  static const background = Color(0xFFF7F9FB);
  static const onBackground = Color(0xFF191C1E);

  static const surface = Color(0xFFF7F9FB);
  static const onSurface = Color(0xFF191C1E);
  static const onSurfaceVariant = Color(0xFF494455);

  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF2F4F6);
  static const surfaceContainer = Color(0xFFECEEF0);
  static const surfaceContainerHigh = Color(0xFFE6E8EA);

  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);
  
  static const outline = Color(0xFF7A7487);
}

class AppTextStyles {
  static TextStyle headline(
      {double fontSize = 20,
      FontWeight fontWeight = FontWeight.bold,
      Color color = AppColors.onSurface}) {
    return GoogleFonts.manrope(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  static TextStyle body(
      {double fontSize = 14,
      FontWeight fontWeight = FontWeight.normal,
      Color color = AppColors.onSurface}) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  static TextStyle label(
      {double fontSize = 12,
      FontWeight fontWeight = FontWeight.w500,
      Color color = AppColors.onSurfaceVariant}) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }
}
