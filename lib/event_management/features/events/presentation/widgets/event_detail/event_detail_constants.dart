import 'package:flutter/material.dart';

/// Visual tokens for the event detail layout (mock: soft minimalist curator-style).
abstract final class EventDetailColors {
  static const Color surface = Color(0xFFF8F9FB);
  static const Color primaryBlue = Color(0xFF0061FF);
  static const Color typePillBg = Color(0xFFEEF2FF);
  static const Color typePillFg = Color(0xFF3730A3);
}

abstract final class EventDetailLayout {
  static const double wideBreakpoint = 900;
  static const double maxContentWidth = 1200;
  static const double cardRadius = 24;
}
