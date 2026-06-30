import 'package:flutter/material.dart';

import 'package:my_app/event_management/features/calendar/shared/calendar_ui_theme.dart';
import 'package:my_app/event_management/features/events/domain/entities/event.dart';

/// Event dashboard — mint page, purple accent, pastel event cards.
abstract final class DashboardUiTheme {
  static const pageBackground = CalendarUiTheme.pageBackground;
  static const cardBackground = CalendarUiTheme.cardBackground;
  static const primary = CalendarUiTheme.primary;
  static const primaryLight = CalendarUiTheme.primaryLight;
  static const border = CalendarUiTheme.border;
  static const textDark = CalendarUiTheme.textDark;
  static const textMuted = CalendarUiTheme.textMuted;

  static const statToday = Color(0xFF1A9B84);
  static const statTodayLight = Color(0xFFE6F7F3);
  static const statUpcoming = Color(0xFF7C3AED);
  static const statUpcomingLight = Color(0xFFF3E8FF);
  static const statEnded = Color(0xFFE05252);
  static const statEndedLight = Color(0xFFFEECEC);

  static const cardRadius = 20.0;
  static const cardRadiusSm = 14.0;

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static BoxDecoration cardDecoration({Color? tint}) => BoxDecoration(
        color: tint ?? cardBackground,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: border),
        boxShadow: cardShadow,
      );

  static Color eventFill(EventType type) =>
      CalendarUiTheme.weekBlockFill(type.name);

  static Color eventText(EventType type) =>
      CalendarUiTheme.weekBlockText(type.name);

  static Color eventAccent(EventType type) =>
      CalendarUiTheme.legendColor(type.name);

  static IconData eventIcon(EventType type) {
    switch (type) {
      case EventType.meeting:
        return Icons.videocam_rounded;
      case EventType.task:
        return Icons.task_alt_rounded;
      case EventType.reminder:
        return Icons.notifications_active_rounded;
      case EventType.personal:
        return Icons.person_rounded;
    }
  }

  static String greeting() {
    final h = DateTime.now().hour;
    if (h < 5) return 'Good night';
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    if (h < 21) return 'Good evening';
    return 'Good night';
  }
}
