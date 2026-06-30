import 'package:flutter/material.dart';

/// Frontend-only calendar colors — do not use API [display_color].
class CalendarPalette {
  CalendarPalette._();

  static const meeting = Color(0xFFE24B4A);
  static const task = Color(0xFF378ADD);
  static const reminder = Color(0xFFEF9F27);
  static const personal = Color(0xFF1D9E75);
  static const taskDeadline = Color(0xFFC0392B);
  static const cancelled = Color(0xFF9CA3AF);

  static const urgent = Color(0xFFC0392B);
  static const high = Color(0xFFE24B4A);
  static const medium = Color(0xFFEF9F27);
  static const low = Color(0xFF1D9E75);

  static Color eventTypeColor(String type, {String? userColorHex}) {
    if (userColorHex != null && userColorHex.isNotEmpty) {
      final parsed = _parseHex(userColorHex);
      if (parsed != null) return parsed;
    }
    switch (type.toLowerCase()) {
      case 'task':
        return task;
      case 'reminder':
        return reminder;
      case 'personal':
        return personal;
      case 'meeting':
      default:
        return meeting;
    }
  }

  static Color priorityBorder(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'urgent':
        return urgent;
      case 'high':
        return high;
      case 'medium':
        return medium;
      case 'low':
        return low;
      default:
        return Colors.transparent;
    }
  }

  static Color? dotColor(String dotType) {
    switch (dotType.toLowerCase()) {
      case 'meeting':
        return meeting;
      case 'task':
        return task;
      case 'reminder':
        return reminder;
      case 'personal':
        return personal;
      default:
        return task;
    }
  }

  static Color? _parseHex(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      if (clean.length == 6) {
        return Color(int.parse('FF$clean', radix: 16));
      }
      if (clean.length == 8) {
        return Color(int.parse(clean, radix: 16));
      }
    } catch (_) {}
    return null;
  }
}
