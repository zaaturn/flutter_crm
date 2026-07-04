import 'package:flutter/material.dart';

import '../../domain/entities/calendar_grid_event.dart';

/// Mobile calendar — cream / terracotta (reference mockups).
abstract final class MobileCalendarTheme {
  static const background = Color(0xFFFAF9F6);
  static const segmentBg = Color(0xFFF2EDE4);
  static const terracotta = Color(0xFFC05C39);
  static const terracottaDark = Color(0xFF9E4A33);
  static const selectedCell = Color(0xFFF5E8E4);
  static const textDark = Color(0xFF1F1814);
  static const textMuted = Color(0xFF8B7B72);
  static const card = Colors.white;
  static const border = Color(0xFFE8DDD4);

  static const meeting = Color(0xFFE57373);
  static const task = Color(0xFF5C8FD6);
  static const reminder = Color(0xFF9B7FD4);
  static const personal = Color(0xFF66BB6A);

  static Color stripForType(String type) {
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

  /// Solid fill for week-view event blocks (reference mockup).
  static Color weekBlockFill(CalendarGridEvent e) {
    if (e.isTaskDeadline) return const Color(0xFFE07A5F);
    return stripForType(e.eventType);
  }
}
