import 'package:flutter/material.dart';
import '../../features/events/domain/entities/event.dart';

class ColorUtils {
  ColorUtils._();

  static Color fromHex(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static String toHex(Color color) =>
      '#${color.value.toRadixString(16).substring(2).toUpperCase()}';

  static Color eventTypeColor(EventType type) {
    switch (type) {
      case EventType.meeting:  return const Color(0xFFE24B4A);
      case EventType.task:     return const Color(0xFF378ADD);
      case EventType.reminder: return const Color(0xFFEF9F27);
      case EventType.personal: return const Color(0xFF1D9E75);
    }
  }

  static Color eventTypeBgColor(EventType type) {
    switch (type) {
      case EventType.meeting:  return const Color(0xFFFCEBEB);
      case EventType.task:     return const Color(0xFFE6F1FB);
      case EventType.reminder: return const Color(0xFFFAEEDA);
      case EventType.personal: return const Color(0xFFE1F5EE);
    }
  }

  static Color eventTypeTextColor(EventType type) {
    switch (type) {
      case EventType.meeting:  return const Color(0xFFA32D2D);
      case EventType.task:     return const Color(0xFF0C447C);
      case EventType.reminder: return const Color(0xFF633806);
      case EventType.personal: return const Color(0xFF085041);
    }
  }

  static Color colorFromEventDisplay(String hexColor, EventType type) {
    if (hexColor.isNotEmpty) return fromHex(hexColor);
    return eventTypeColor(type);
  }
}