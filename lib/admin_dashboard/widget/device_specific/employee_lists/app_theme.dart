// lib/admin_dashboard/utils/app_theme.dart
import 'package:flutter/material.dart';

class AppColors {
  // Teal (Primary) — matches AdminDashboardTheme ──
  static const Color primary = Color(0xFF2F7D6D);
  static const Color primaryDark = Color(0xFF1F5F52);
  static const Color primaryLight = Color(0xFFE3F2EE); // For light backgrounds

  // ── Status Colors ───────────────────────────────
  static const Color active = Color(0xFF10B981); // Emerald Green
  static const Color offline = Color(0xFFEF4444); // Red

  // ── Neutral Grays ───────────────────────────────
  static const Color textBody = Color(0xFF6B7F78);
  static const Color textHeading = Color(0xFF1C2B26);
  static const Color textSubtle = Color(0xFF9AABA3);
  static const Color border = Color(0xFFE3EAE6);
  static const Color cardBg = Colors.white;

  // ── Mint canvas (dashboard shell background) ────
  static const Color canvas = Color(0xFFD0E3D8);
  static const Color surfaceMuted = Color(0xFFF4F7F5);
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