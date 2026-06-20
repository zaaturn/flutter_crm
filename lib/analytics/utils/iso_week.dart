import 'package:intl/intl.dart';

/// ISO-8601 week helpers for `year` + `week` query params.
abstract final class IsoWeek {
  IsoWeek._();

  /// ISO week number (1–53). Does not call [weeksInYear] to avoid recursion.
  static int weekNumber(DateTime date) {
    final utc = DateTime.utc(date.year, date.month, date.day);
    final monday = utc.subtract(Duration(days: utc.weekday - DateTime.monday));
    final thursday = monday.add(const Duration(days: 3));
    final isoYear = thursday.year;
    final jan4 = DateTime.utc(isoYear, 1, 4);
    final jan4Monday = jan4.subtract(Duration(days: jan4.weekday - DateTime.monday));
    return ((monday.difference(jan4Monday).inDays) / 7).floor() + 1;
  }

  static int weeksInYear(int year) => weekNumber(DateTime.utc(year, 12, 28));

  static DateTime startOfWeek(int year, int week) {
    final jan4 = DateTime.utc(year, 1, 4);
    final start = jan4.subtract(Duration(days: jan4.weekday - DateTime.monday));
    return start.add(Duration(days: (week - 1) * 7));
  }

  static DateTime endOfWeek(int year, int week) =>
      startOfWeek(year, week).add(const Duration(days: 6));

  static String rangeLabel(int year, int week) {
    final start = startOfWeek(year, week).toLocal();
    final end = endOfWeek(year, week).toLocal();
    final fmt = DateFormat('d MMM');
    return '${fmt.format(start)} – ${fmt.format(end)} $year';
  }

  /// e.g. `Week 24 · 9 Jun – 15 Jun 2026`
  static String weekPickerLabel(int year, int week) =>
      'Week $week · ${rangeLabel(year, week)}';

  static ({int year, int week}) current() {
    final now = DateTime.now();
    final utc = DateTime.utc(now.year, now.month, now.day);
    final monday = utc.subtract(Duration(days: utc.weekday - DateTime.monday));
    final thursday = monday.add(const Duration(days: 3));
    return (year: thursday.year, week: weekNumber(now));
  }
}
