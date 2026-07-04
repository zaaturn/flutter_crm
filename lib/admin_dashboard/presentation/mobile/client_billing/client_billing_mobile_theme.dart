import 'package:flutter/material.dart';

/// Client billing mobile — terracotta / cream (matches payroll).
abstract final class ClientBillingMobileTheme {
  static const background = Color(0xFFFAF9F6);
  static const terracotta = Color(0xFFC05C39);
  static const segmentBg = Color(0xFFF2EDE4);
  static const card = Colors.white;
  static const border = Color(0xFFE8DDD4);
  static const textDark = Color(0xFF1F1814);
  static const textMuted = Color(0xFF8B7B72);
  static const success = Color(0xFF22C55E);
  static const successDark = Color(0xFF15803D);
  static const warning = Color(0xFFC05C39);

  static List<Color> avatarColors = const [
    Color(0xFFE9D5FF),
    Color(0xFFFED7AA),
    Color(0xFFBBF7D0),
    Color(0xFFBFDBFE),
    Color(0xFFFECDD3),
    Color(0xFFFDE68A),
  ];

  static Color avatarBg(int seed) =>
      avatarColors[seed.abs() % avatarColors.length];
}
