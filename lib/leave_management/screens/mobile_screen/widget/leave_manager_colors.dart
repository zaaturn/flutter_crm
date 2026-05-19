import 'package:flutter/material.dart';

/// Palette aligned with LeaveManager / Material theme from the reference HTML.
abstract final class LeaveManagerColors {
  // Zaaturn (mobile) palette: cream + terracotta.
  static const Color background = Color(0xFFFAF3E0);
  static const Color surface = Color(0xFFFAF3E0);
  static const Color headerBar = Color(0xFFFAF3E0);

  static const Color primary = Color(0xFFC05E41); // Terracotta
  static const Color primaryDark = Color(0xFF8E3F2A);

  static const Color onBackground = Color(0xFF3E2723); // Coffee
  static const Color outline = Color(0xFF8D6E63);
  static const Color outlineVariant = Color(0x33C05E41);

  static const Color primaryContainerTint = Color(0x1AC05E41);
  static const Color brandText = primary;

  static const Color tertiaryContainer = Color(0xFFEADBC8); // Beige card
  static const Color onTertiaryContainer = onBackground;
}
