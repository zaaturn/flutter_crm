import 'package:intl/intl.dart';

class DateUtils {
  DateUtils._();

  static String formatDate(DateTime dt) =>
      DateFormat('MMM d, yyyy').format(dt);

  static String formatTime(DateTime dt) =>
      DateFormat.jm().format(dt);

  static String formatDateTime(DateTime dt) =>
      DateFormat('MMM d, yyyy  h:mm a').format(dt);

  static String formatDayHeader(DateTime dt) =>
      DateFormat('EEEE, MMMM d').format(dt);

  static String formatMonthYear(DateTime dt) =>
      DateFormat('MMMM yyyy').format(dt);

  static String formatShortDate(DateTime dt) =>
      DateFormat('EEE, MMM d').format(dt);

  static String formatRelative(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return formatDate(dt);
  }

  static String formatDuration(Duration d) {
    if (d.inHours > 0) {
      final mins = d.inMinutes.remainder(60);
      return mins > 0 ? '${d.inHours}h ${mins}m' : '${d.inHours}h';
    }
    return '${d.inMinutes}m';
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool isToday(DateTime dt) => isSameDay(dt, DateTime.now());

  static bool isPast(DateTime dt) => dt.isBefore(DateTime.now());

  static DateTime startOfDay(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  static DateTime endOfDay(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day, 23, 59, 59);

  static DateTime startOfMonth(DateTime dt) =>
      DateTime(dt.year, dt.month, 1);

  static DateTime endOfMonth(DateTime dt) =>
      DateTime(dt.year, dt.month + 1, 0, 23, 59, 59);

  static List<DateTime> daysInMonth(DateTime month) {
    final start = startOfMonth(month);
    final end = endOfMonth(month);
    return List.generate(
      end.day,
          (i) => DateTime(start.year, start.month, i + 1),
    );
  }

  static DateTime nextHour() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, now.hour + 1, 0);
  }

  /// Returns DateTime with date from [date] and time from [time]
  static DateTime combine(DateTime date, DateTime time) =>
      DateTime(date.year, date.month, date.day, time.hour, time.minute);
}