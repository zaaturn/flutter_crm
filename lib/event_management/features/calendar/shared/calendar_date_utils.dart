class CalendarDateUtils {
  CalendarDateUtils._();

  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static String dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static DateTime startOfWeek(DateTime d, {int weekStart = DateTime.monday}) {
    final diff = (d.weekday - weekStart + 7) % 7;
    return dateOnly(d.subtract(Duration(days: diff)));
  }

  static DateTime endOfWeek(DateTime d, {int weekStart = DateTime.monday}) {
    return startOfWeek(d, weekStart: weekStart).add(const Duration(days: 6));
  }

  static List<DateTime> daysInMonthGrid(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final start = startOfWeek(first);
    return List.generate(42, (i) => start.add(Duration(days: i)));
  }

  static DateTime rangeStartForView(CalendarViewKind view, DateTime anchor) {
    switch (view) {
      case CalendarViewKind.month:
        final first = DateTime(anchor.year, anchor.month, 1);
        return startOfWeek(first);
      case CalendarViewKind.week:
        return startOfWeek(anchor);
      case CalendarViewKind.day:
        return dateOnly(anchor);
      case CalendarViewKind.agenda:
        return dateOnly(anchor);
    }
  }

  static DateTime rangeEndForView(CalendarViewKind view, DateTime anchor) {
    switch (view) {
      case CalendarViewKind.month:
        final last = DateTime(anchor.year, anchor.month + 1, 0);
        return endOfWeek(last);
      case CalendarViewKind.week:
        return endOfWeek(anchor);
      case CalendarViewKind.day:
        return dateOnly(anchor);
      case CalendarViewKind.agenda:
        return dateOnly(anchor.add(const Duration(days: 30)));
    }
  }
}

enum CalendarViewKind { month, week, day, agenda }
