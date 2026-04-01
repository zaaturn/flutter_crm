import 'package:intl/intl.dart';

/// API timestamps are often UTC without a `Z` suffix; parsing them as local breaks UI.
/// We normalize to a UTC [DateTime] and always format with [.toLocal()] for display.
class EventInstant {
  EventInstant._();

  static final RegExp _hasTz = RegExp(r'Z$|[+-]\d{2}:\d{2}$');

  /// Parse Django/DRF-style ISO strings. Naive values are treated as UTC.
  static DateTime parseApi(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return DateTime.now().toUtc();
    if (s.endsWith('Z') || _hasTz.hasMatch(s)) {
      return DateTime.parse(s).toUtc();
    }
    var core = s;
    final dot = core.indexOf('.');
    if (dot != -1) core = core.substring(0, dot);
    return DateTime.parse('${core}Z').toUtc();
  }

  static DateTime toLocalWall(DateTime utcOrLocal) => utcOrLocal.toLocal();

  static String formatTimeRange(
    DateTime start,
    DateTime end, {
    bool allDay = false,
  }) {
    if (allDay) return 'All day';
    final a = start.toLocal();
    final b = end.toLocal();
    return '${DateFormat.jm().format(a)} – ${DateFormat.jm().format(b)}';
  }

  static String formatShortDate(DateTime instant) =>
      DateFormat('EEE, MMM d').format(instant.toLocal());

  static String formatMediumDate(DateTime instant) =>
      DateFormat('MMM d, yyyy').format(instant.toLocal());

  /// Calendar cell [day] is a date in the visible month (local midnight).
  static bool isSameLocalDay(DateTime instant, DateTime day) {
    final l = instant.toLocal();
    return l.year == day.year && l.month == day.month && l.day == day.day;
  }
}
