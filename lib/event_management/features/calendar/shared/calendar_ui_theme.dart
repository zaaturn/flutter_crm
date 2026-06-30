import 'package:flutter/material.dart';

/// Calendar UI — purple accent, white cards, pastel event blocks by type.
abstract final class CalendarUiTheme {
  static const primary = Color(0xFF7C3AED);
  static const primaryLight = Color(0xFFF3E8FF);
  static const pageBackground = Color(0xFFF0F7F4);
  static const cardBackground = Colors.white;
  static const border = Color(0xFFE2E8E6);
  static const textDark = Color(0xFF1A2E28);
  static const textMuted = Color(0xFF6B7F78);
  static const surface = Color(0xFFF0F7F4);

  // Filter legend swatches
  static const legendMeeting = Color(0xFF7ECFC0);
  static const legendTask = Color(0xFFF5B8C8);
  static const legendReminder = Color(0xFFC9B8F0);
  static const legendPersonal = Color(0xFFF5C9A8);

  // Pastel week block fills + text
  static const blockMeeting = Color(0xFFD4F0EB);
  static const blockMeetingText = Color(0xFF1A6B5C);
  static const blockTask = Color(0xFFFCE4EC);
  static const blockTaskText = Color(0xFF9E3D5C);
  static const blockReminder = Color(0xFFEDE4FC);
  static const blockReminderText = Color(0xFF5B3FA0);
  static const blockPersonal = Color(0xFFFEECD8);
  static const blockPersonalText = Color(0xFF9A5B20);
  static const blockTaskDeadline = Color(0xFFFFF0F0);
  static const blockTaskDeadlineText = Color(0xFFC0392B);

  static const allEventTypes = ['meeting', 'task', 'reminder', 'personal'];

  static Color legendColor(String type) {
    switch (type.toLowerCase()) {
      case 'task':
        return legendTask;
      case 'reminder':
        return legendReminder;
      case 'personal':
        return legendPersonal;
      case 'meeting':
      default:
        return legendMeeting;
    }
  }

  static Color weekBlockFill(String type, {bool isTaskDeadline = false}) {
    if (isTaskDeadline) return blockTaskDeadline;
    switch (type.toLowerCase()) {
      case 'task':
        return blockTask;
      case 'reminder':
        return blockReminder;
      case 'personal':
        return blockPersonal;
      case 'meeting':
      default:
        return blockMeeting;
    }
  }

  static Color weekBlockText(String type, {bool isTaskDeadline = false}) {
    if (isTaskDeadline) return blockTaskDeadlineText;
    switch (type.toLowerCase()) {
      case 'task':
        return blockTaskText;
      case 'reminder':
        return blockReminderText;
      case 'personal':
        return blockPersonalText;
      case 'meeting':
      default:
        return blockMeetingText;
    }
  }
}
