import 'package:my_app/analytics/utils/iso_week.dart';

/// One day of worked / break time for the employee weekly activity chart.
class WeeklyActivityDay {
  final DateTime date;
  final Duration netWork;
  final Duration totalBreak;

  /// Company workday cap used by analytics / auto-logout.
  static const maxWorkDay = Duration(hours: 9);

  const WeeklyActivityDay({
    required this.date,
    this.netWork = Duration.zero,
    this.totalBreak = Duration.zero,
  });

  WeeklyActivityDay copyWith({
    DateTime? date,
    Duration? netWork,
    Duration? totalBreak,
  }) {
    return WeeklyActivityDay(
      date: date ?? this.date,
      netWork: netWork ?? this.netWork,
      totalBreak: totalBreak ?? this.totalBreak,
    );
  }

  /// Clamped so forgotten check-outs never render as 70h+ bars.
  Duration get cappedNetWork =>
      netWork > maxWorkDay ? maxWorkDay : netWork;

  double get workedHours => cappedNetWork.inSeconds / 3600;
  double get breakHours => totalBreak.inSeconds / 3600;
}

/// Mon–Sun calendar week activity for the signed-in employee.
class WeeklyActivityModel {
  final List<WeeklyActivityDay> days;

  const WeeklyActivityModel({required this.days});

  Duration get totalWorked =>
      days.fold(Duration.zero, (sum, d) => sum + d.cappedNetWork);

  Duration get totalBreak =>
      days.fold(Duration.zero, (sum, d) => sum + d.totalBreak);

  /// Empty scaffold for the ISO week requested from the API.
  factory WeeklyActivityModel.forIsoWeek(int year, int week) {
    final startUtc = IsoWeek.startOfWeek(year, week);
    final monday = DateTime(startUtc.year, startUtc.month, startUtc.day);
    final days = List.generate(
      7,
      (i) => WeeklyActivityDay(date: monday.add(Duration(days: i))),
    );
    return WeeklyActivityModel(days: days);
  }

  /// Empty scaffold for the calendar week containing [anchor].
  factory WeeklyActivityModel.forCalendarWeek([DateTime? anchor]) {
    final now = (anchor ?? DateTime.now()).toLocal();
    final monday = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - DateTime.monday));
    final days = List.generate(
      7,
      (i) => WeeklyActivityDay(date: monday.add(Duration(days: i))),
    );
    return WeeklyActivityModel(days: days);
  }

  WeeklyActivityModel withDay(
    DateTime date,
    Duration netWork,
    Duration totalBreak,
  ) {
    final key = _dateKey(date);
    return WeeklyActivityModel(
      days: days
          .map(
            (d) => _dateKey(d.date) == key
                ? d.copyWith(netWork: netWork, totalBreak: totalBreak)
                : d,
          )
          .toList(),
    );
  }

  WeeklyActivityModel mergeToday(WeeklyActivityDay today) =>
      mergeDayKeepingMax(today);

  /// Updates one day without lowering hours already loaded from the API.
  WeeklyActivityModel mergeDayKeepingMax(WeeklyActivityDay patch) {
    final key = _dateKey(patch.date);
    return WeeklyActivityModel(
      days: days
          .map(
            (d) {
              if (_dateKey(d.date) != key) return d;
              return d.copyWith(
                netWork: patch.netWork.inSeconds > d.netWork.inSeconds
                    ? patch.netWork
                    : d.netWork,
                totalBreak: patch.totalBreak.inSeconds > d.totalBreak.inSeconds
                    ? patch.totalBreak
                    : d.totalBreak,
              );
            },
          )
          .toList(),
    );
  }

  factory WeeklyActivityModel.fromJson(
    Map<String, dynamic> json, {
    DateTime? anchor,
    int? year,
    int? week,
  }) {
    final scaffold = (year != null && week != null)
        ? WeeklyActivityModel.forIsoWeek(year, week)
        : WeeklyActivityModel.forCalendarWeek(anchor);
    final data = _unwrap(json);
    final list = _extractDayList(data);

    if (list.isEmpty) return scaffold;

    var result = scaffold;
    for (final item in list) {
      if (item is! Map) continue;
      final m = Map<String, dynamic>.from(item);
      final date = _parseDate(m['date'] ?? m['day'] ?? m['attendance_date']);
      if (date == null) continue;

      final netWork = _parseWorkDuration(m);
      final totalBreak = _parseBreakDuration(m);
      final capped = netWork > WeeklyActivityDay.maxWorkDay
          ? WeeklyActivityDay.maxWorkDay
          : netWork;

      result = result.withDay(date, capped, totalBreak);
    }
    return result;
  }

  static List<dynamic> _extractDayList(Map<String, dynamic> data) {
    for (final key in const [
      'days',
      'rows',
      'daily_rows',
      'daily',
      'results',
      'attendance_days',
      'week_days',
    ]) {
      final value = data[key];
      if (value is List) return value;
    }
    return const [];
  }

  static Duration _parseWorkDuration(Map<String, dynamic> m) {
    return _parseDuration(
      seconds: m['net_work_seconds'] ??
          m['total_worked_seconds'] ??
          m['worked_seconds'],
      minutes: m['net_work_minutes'] ??
          m['total_worked_minutes'] ??
          m['worked_minutes'],
      hours: m['total_worked_hours'] ??
          m['total_worked'] ??
          m['total_work_hours'] ??
          m['net_hours'] ??
          m['hours'] ??
          m['worked_hours'],
    );
  }

  static Duration _parseBreakDuration(Map<String, dynamic> m) {
    return _parseDuration(
      seconds: m['total_break_seconds'] ?? m['break_seconds'],
      minutes: m['total_break_minutes'] ?? m['break_minutes'],
      hours: m['total_break_hours'] ??
          m['break_hours'] ??
          m['total_break'],
    );
  }

  static Map<String, dynamic> _unwrap(Map<String, dynamic> json) {
    if (json['days'] is List ||
        json['rows'] is List ||
        json['daily_rows'] is List) {
      return json;
    }
    final nested = json['data'] ?? json['attendance'] ?? json['week'];
    if (nested is Map) return Map<String, dynamic>.from(nested);
    return json;
  }

  static String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    try {
      final d = DateTime.parse(v.toString()).toLocal();
      return DateTime(d.year, d.month, d.day);
    } catch (_) {
      return null;
    }
  }

  static Duration _parseDuration({
    dynamic seconds,
    dynamic minutes,
    dynamic hours,
  }) {
    final sec = _int(seconds);
    if (sec > 0) return Duration(seconds: sec);

    final min = _int(minutes);
    if (min > 0) return Duration(minutes: min);

    if (hours != null) {
      final h = _double(hours);
      if (h > 0) return Duration(milliseconds: (h * 3600000).round());
    }
    return Duration.zero;
  }

  static int _int(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _double(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}

String formatWeeklyHours(Duration d) {
  if (d.inSeconds <= 0) return '—';
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  if (m == 0) return '${h}h';
  return '${h}h ${m}m';
}
