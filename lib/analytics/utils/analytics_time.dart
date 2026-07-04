import 'package:intl/intl.dart';

/// Formats API check-in/out values (`09:15:00`, ISO datetime, etc.).
abstract final class AnalyticsTime {
  AnalyticsTime._();

  static String? format(dynamic value) {
    if (value == null) return null;
    final raw = value.toString().trim();
    if (raw.isEmpty) return null;

    try {
      if (raw.contains('T') || raw.contains('-')) {
        return DateFormat('hh:mm a').format(DateTime.parse(raw).toLocal());
      }
      final parts = raw.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final second = parts.length > 2 ? int.parse(parts[2]) : 0;
        final dt = DateTime(2000, 1, 1, hour, minute, second);
        return DateFormat('hh:mm a').format(dt);
      }
    } catch (_) {
      return raw;
    }
    return raw;
  }

  /// 24-hour `HH:mm` for compact mobile attendance rows.
  static String? format24(dynamic value) {
    if (value == null) return null;
    final raw = value.toString().trim();
    if (raw.isEmpty) return null;

    try {
      if (raw.contains('T') || raw.contains('-')) {
        final dt = DateTime.parse(raw).toLocal();
        return DateFormat('HH:mm').format(dt);
      }
      final parts = raw.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return '${hour.toString().padLeft(2, '0')}:'
            '${minute.toString().padLeft(2, '0')}';
      }
    } catch (_) {
      return raw;
    }
    return raw;
  }
}
