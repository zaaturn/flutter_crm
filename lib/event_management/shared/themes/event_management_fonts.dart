import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme.dart';

/// Plus Jakarta Sans via [google_fonts] for event list and detail screens.
abstract final class EventManagementFonts {
  static TextStyle jakarta({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
    double height = 1.25,
    double letterSpacing = 0,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? AppTheme.textPrimary,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle screenTitle() => jakarta(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.6,
        height: 1.15,
      );

  static TextStyle cardTitle() => jakarta(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.2,
      );

  static TextStyle cardMeta() => jakarta(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: AppTheme.textSecondary,
        height: 1.3,
      );

  static TextStyle cardMetaEmphasis() => jakarta(
        fontSize: 13.5,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
        height: 1.3,
      );

  static TextStyle chipLabel() => jakarta(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      );

  static TextStyle detailSectionTitle() => jakarta(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        height: 1.2,
      );

  static TextStyle detailHeadline() => jakarta(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        height: 1.15,
      );

  static TextStyle detailScheduleLabel() => jakarta(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.05,
        color: AppTheme.textHint,
      );

  static TextStyle detailScheduleDate() => jakarta(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        height: 1.2,
      );

  static TextStyle detailScheduleTime() => jakarta(
        fontSize: 17,
        fontWeight: FontWeight.w700,
      );

  static TextStyle bodyReading() => jakarta(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.55,
      );
}
