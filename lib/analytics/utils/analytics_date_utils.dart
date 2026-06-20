import 'package:intl/intl.dart';

import 'iso_week.dart';

/// Date helpers for analytics API query params and presets.
abstract final class AnalyticsDateUtils {
  AnalyticsDateUtils._();

  static String toApiDate(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  static DateTime parseApiDate(String value) {
    final parts = value.split('-');
    if (parts.length == 3) {
      return DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    }
    return DateTime.parse(value).toLocal();
  }

  /// Today if it falls in the ISO week, otherwise that week's Monday.
  static String defaultDayKeyForIsoWeek(int year, int week) {
    final todayKey = toApiDate(_today());
    for (final opt in isoWeekDayOptions(year, week)) {
      if (opt.key == todayKey) return todayKey;
    }
    return isoWeekDayOptions(year, week).first.key;
  }

  /// Dropdown options: `W25 Monday · 16 Jun`, etc. (no "All days").
  static List<({String key, String label})> isoWeekDayOptions(int year, int week) {
    final start = IsoWeek.startOfWeek(year, week).toLocal();
    final weekdayFmt = DateFormat('EEEE');
    final shortFmt = DateFormat('dd MMM');
    return List.generate(7, (i) {
      final day = DateTime(start.year, start.month, start.day + i);
      final key = toApiDate(day);
      return (
        key: key,
        label: 'W$week ${weekdayFmt.format(day)} · ${shortFmt.format(day)}',
      );
    });
  }
  /// Monday–Sunday of the current calendar week.
  static ({DateTime start, DateTime end}) thisWeek() {
    final today = _today();
    final monday = today.subtract(Duration(days: today.weekday - DateTime.monday));
    return (start: monday, end: monday.add(const Duration(days: 6)));
  }

  /// 1st of month through today.
  static ({DateTime start, DateTime end}) thisMonth() {
    final today = _today();
    return (start: DateTime(today.year, today.month, 1), end: today);
  }

  /// Full previous calendar month.
  static ({DateTime start, DateTime end}) lastMonth() {
    final today = _today();
    final firstThisMonth = DateTime(today.year, today.month, 1);
    final lastDayPrev = firstThisMonth.subtract(const Duration(days: 1));
    return (
      start: DateTime(lastDayPrev.year, lastDayPrev.month, 1),
      end: lastDayPrev,
    );
  }

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
}

enum DateRangePreset { thisWeek, thisMonth, lastMonth, custom }

extension DateRangePresetX on DateRangePreset {
  String get label => switch (this) {
        DateRangePreset.thisWeek => 'This Week',
        DateRangePreset.thisMonth => 'This Month',
        DateRangePreset.lastMonth => 'Last Month',
        DateRangePreset.custom => 'Custom Range',
      };

  ({DateTime start, DateTime end}) get range => switch (this) {
        DateRangePreset.thisWeek => AnalyticsDateUtils.thisWeek(),
        DateRangePreset.thisMonth => AnalyticsDateUtils.thisMonth(),
        DateRangePreset.lastMonth => AnalyticsDateUtils.lastMonth(),
        DateRangePreset.custom => AnalyticsDateUtils.thisMonth(),
      };
}
