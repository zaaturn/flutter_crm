// lib/admin_dashboard/utils/app_theme.dart
import 'package:flutter/material.dart';

class AppColors {
  // Purple (Primary) ───────────────────
  static const Color primary = Color(0xFF6F42C1);
  static const Color primaryLight = Color(0xFFEBE5F7); // For light backgrounds

  // ── Status Colors ───────────────────────────────
  static const Color active = Color(0xFF10B981); // Emerald Green
  static const Color offline = Color(0xFFEF4444); // Red

  // ── Neutral Grays ───────────────────────────────
  static const Color textBody = Color(0xFF6C757D);
  static const Color textHeading = Color(0xFF1F2937);
  static const Color textSubtle = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE2E8F0);
  static const Color cardBg = Colors.white;
}

class AppTextStyles {
  // Title (Card name)
  static const TextStyle title = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textHeading,
    fontFamily: 'Roboto', // Replace with your primary font
  );

  // Subtitle (Card designation)
  static const TextStyle subtitle = TextStyle(
    fontSize: 12,
    color: AppColors.textBody,
    fontFamily: 'Roboto',
  );

  // Small Text (ID, tags)
  static const TextStyle small = TextStyle(
    fontSize: 11,
    color: AppColors.textSubtle,
    fontFamily: 'Roboto',
  );

  // Button text
  static const TextStyle button = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    fontFamily: 'Roboto',
  );
}