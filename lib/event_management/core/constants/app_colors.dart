import 'package:flutter/material.dart';


class AppColors {
  // ── Primary / Accent ──
  static const Color primary = Color(0xFF6366F1);          // indigo-500
  static const Color primaryLight = Color(0xFFA5B4FC);     // indigo-300
  static const Color primaryExtraLight = Color(0xFFEEF2FF); // indigo-50

  // ── Neutral ──
  static const Color background = Color(0xFFFFFFFF); // Pure White
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E5ED);
  static const Color borderLight = Color(0xFFEEF0F3);

  // ── Text ──
  static const Color textPrimary = Color(0xFF1E2130);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);

  // ── Danger ──
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerLight = Color(0xFFFEF2F2);
  static const Color dangerBorder = Color(0xFFfca5a5);

  // ── ── Event‑type colours (match the React version exactly) ── ──
  static const Color meetingText = Color(0xFF6366F1);
  static const Color meetingBg = Color(0xFFEEF2FF);
  static const Color meetingBorder = Color(0xFFA5B4FC);

  static const Color callText = Color(0xFFF59E0B);
  static const Color callBg = Color(0xFFFFFBEB);
  static const Color callBorder = Color(0xFFfcd34d);

  static const Color followUpText = Color(0xFF10B981);
  static const Color followUpBg = Color(0xFFECFDF5);
  static const Color followUpBorder = Color(0xFF6EE7B7);

  static const Color taskText = Color(0xFFEF4444);
  static const Color taskBg = Color(0xFFFEF2F2);
  static const Color taskBorder = Color(0xFFfca5a5);
}

/// Convenience – returns [text, bg, border] for a given event-type string.
class EventTypeColor {
  final Color text;
  final Color bg;
  final Color border;

  const EventTypeColor({required this.text, required this.bg, required this.border});

  static const Map<String, EventTypeColor> _map = {
    'meeting': EventTypeColor(text: AppColors.meetingText, bg: AppColors.meetingBg, border: AppColors.meetingBorder),
    'call': EventTypeColor(text: AppColors.callText, bg: AppColors.callBg, border: AppColors.callBorder),
    'followup': EventTypeColor(text: AppColors.followUpText, bg: AppColors.followUpBg, border: AppColors.followUpBorder),
    'task': EventTypeColor(text: AppColors.taskText, bg: AppColors.taskBg, border: AppColors.taskBorder),
  };

  static EventTypeColor of(String type) => _map[type] ?? _map['meeting']!;
}