import 'package:flutter/material.dart';

abstract final class HolidayUiTheme {
  static const orange = Color(0xFFFF8C00);
  static const bg = Color(0xFFFFF3E0);
  static const bgDark = Color(0xFFFF6B00);
  static const dayTint = Color(0xFFFFFAF5);
  static const text = Color(0xFFE65100);
  static const sundayTint = Color(0xFFF5F5F5);

  static const flag = '🇮🇳';

  static LinearGradient bannerGradient = const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [orange, bgDark],
  );

  static BoxDecoration chipDecoration = BoxDecoration(
    color: bg,
    borderRadius: BorderRadius.circular(4),
    border: const Border(
      left: BorderSide(color: orange, width: 3),
    ),
  );
}
