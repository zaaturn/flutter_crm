import 'package:intl/intl.dart';

/// Indian Standard Time (IST, UTC+5:30) for UI display and day grouping.
abstract final class IndianTime {
  IndianTime._();

  static const Duration _offset = Duration(hours: 5, minutes: 30);

  /// Wall-clock components in IST (naive [DateTime]).
  static DateTime toIst(DateTime instant) {
    final utc = instant.isUtc ? instant : instant.toUtc();
    return utc.add(_offset);
  }

  static DateTime nowIst() => toIst(DateTime.now().toUtc());

  static bool isSameIstDay(DateTime a, DateTime b) {
    final ia = toIst(a);
    final ib = toIst(b);
    return ia.year == ib.year && ia.month == ib.month && ia.day == ib.day;
  }

  static String formatTime(DateTime instant) =>
      DateFormat('hh:mm a').format(toIst(instant));

  static String formatDayAndTime(DateTime instant) =>
      '${DateFormat('EEE, MMM d').format(toIst(instant))} • ${formatTime(instant)}';

  static String formatDateHeader(DateTime instant) =>
      DateFormat('MMMM dd, yyyy').format(toIst(instant));

  /// Today / Yesterday / month-day labels using IST calendar days.
  static String groupLabel(DateTime instant) {
    final now = nowIst();
    final date = toIst(instant);
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    }
    return DateFormat('MMMM dd').format(date);
  }

  /// Compact relative label for notification cards (IST).
  static String formatRelative(DateTime instant) {
    final ist = toIst(instant);
    final diff = nowIst().difference(ist);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (isSameIstDay(instant, DateTime.now().toUtc())) {
      return formatTime(instant);
    }
    if (diff.inDays < 7) return DateFormat('EEE').format(ist);
    return DateFormat('MMM d').format(ist);
  }
}
