import 'package:flutter/material.dart';
import 'package:my_app/event_management/features/events/domain/entities/event.dart';

/// Semantic colors aligned with [EventType] labels in the domain layer.
/// Matches the professional square-box calendar theme.
class EventColors {
  EventColors._();

  // ── Solid accent colors (left bar, dot marker) ────────────────────────────
  static const Color meeting  = Color(0xFFE24B4A);
  static const Color task     = Color(0xFF378ADD);
  static const Color reminder = Color(0xFFEF9F27);
  static const Color personal = Color(0xFF1D9E75);

  // ── Tinted background fills (event pill bg, badge bg) ─────────────────────
  static const Color meetingBg  = Color(0xFFFCEBEB);
  static const Color taskBg     = Color(0xFFE6F1FB);
  static const Color reminderBg = Color(0xFFFAEEDA);
  static const Color personalBg = Color(0xFFE1F5EE);

  // ── Text on tinted backgrounds (readable, same family as bg) ──────────────
  static const Color meetingText  = Color(0xFFA32D2D);
  static const Color taskText     = Color(0xFF0C447C);
  static const Color reminderText = Color(0xFF633806);
  static const Color personalText = Color(0xFF085041);

  // ── Color picker palette (shown in event create / edit form) ──────────────
  static const List<Color> palette = [
    Color(0xFFE24B4A), // meeting red
    Color(0xFF378ADD), // task blue
    Color(0xFFEF9F27), // reminder amber
    Color(0xFF1D9E75), // personal green
    Color(0xFF534AB7), // purple
    Color(0xFFD4537E), // pink
    Color(0xFF888780), // gray
    Color(0xFFD85A30), // coral
  ];

  // ── Solid lookup ──────────────────────────────────────────────────────────
  static Color solid(EventType type) {
    switch (type) {
      case EventType.meeting:  return meeting;
      case EventType.task:     return task;
      case EventType.reminder: return reminder;
      case EventType.personal: return personal;
    }
  }

  // ── Tinted background lookup ──────────────────────────────────────────────
  static Color background(EventType type) {
    switch (type) {
      case EventType.meeting:  return meetingBg;
      case EventType.task:     return taskBg;
      case EventType.reminder: return reminderBg;
      case EventType.personal: return personalBg;
    }
  }

  // ── Text on tinted background lookup ─────────────────────────────────────
  static Color text(EventType type) {
    switch (type) {
      case EventType.meeting:  return meetingText;
      case EventType.task:     return taskText;
      case EventType.reminder: return reminderText;
      case EventType.personal: return personalText;
    }
  }

  /// Resolves a hex color override string first, falls back to [solid].
  /// Used by [Event.colorOverride] — if the user picked a custom color,
  /// that takes priority over the type's default solid color.
  static Color fromEvent(String hexOverride, EventType type) {
    if (hexOverride.isNotEmpty) {
      try {
        return Color(
          int.parse('0xFF${hexOverride.replaceAll('#', '')}'),
        );
      } catch (_) {}
    }
    return solid(type);
  }

  /// Pastel chip background from API [Event.displayColor] / type (not hardcoded titles).
  static Color chipFillForEvent(Event event) {
    final base = fromEvent(event.colorOverride, event.type);
    return Color.lerp(Colors.white, base, 0.22) ?? base;
  }

  /// Readable text on [chipFillForEvent].
  static Color chipTextForEvent(Event event) {
    final base = fromEvent(event.colorOverride, event.type);
    return Color.lerp(base, const Color(0xFF111827), 0.52) ?? base;
  }
}