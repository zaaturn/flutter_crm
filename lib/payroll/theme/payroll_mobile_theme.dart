import 'package:flutter/material.dart';

/// Mobile payroll — terracotta / cream (matches app calendar & events).
abstract final class PayrollMobileTheme {
  static const background = Color(0xFFFAF9F6);
  static const terracotta = Color(0xFFC05C39);
  static const terracottaDark = Color(0xFF9E4A33);
  static const segmentBg = Color(0xFFF2EDE4);
  static const card = Colors.white;
  static const border = Color(0xFFE8DDD4);
  static const textDark = Color(0xFF1F1814);
  static const textMuted = Color(0xFF8B7B72);
  static const paidGreen = Color(0xFF22C55E);
  static const paidGreenDark = Color(0xFF15803D);
  static const pendingOrange = Color(0xFFC05C39);
  static const onTerracotta = Color(0xFFFAF9F6);
  static const actionBar = Color(0xFF111827);

  static List<Color> avatarColors = const [
    Color(0xFFE9D5FF),
    Color(0xFFFED7AA),
    Color(0xFFBBF7D0),
    Color(0xFFBFDBFE),
    Color(0xFFFECDD3),
    Color(0xFFFDE68A),
  ];

  static Color avatarBg(int seed) => avatarColors[seed.abs() % avatarColors.length];
}
