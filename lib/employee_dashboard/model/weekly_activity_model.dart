/// One day of worked / break time for the employee weekly activity chart.
class WeeklyActivityDay {
  final DateTime date;
  final Duration netWork;
  final Duration totalBreak;

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

  double get workedHours => netWork.inSeconds / 3600;
  double get breakHours => totalBreak.inSeconds / 3600;
}

/// Mon–Sun calendar week activity for the signed-in employee.
class WeeklyActivityModel {
  final List<WeeklyActivityDay> days;

  const WeeklyActivityModel({required this.days});

  Duration get totalWorked =>
      days.fold(Duration.zero, (sum, d) => sum + d.netWork);

  Duration get totalBreak =>
      days.fold(Duration.zero, (sum, d) => sum + d.totalBreak);

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
      withDay(today.date, today.netWork, today.totalBreak);

  factory WeeklyActivityModel.fromJson(
    Map<String, dynamic> json, {
    DateTime? anchor,
  }) {
    final scaffold = WeeklyActivityModel.forCalendarWeek(anchor);
    final data = _unwrap(json);
    final list = data['days'] ??
        data['rows'] ??
        data['daily_rows'] ??
        data['daily'] ??
        data['results'];

    if (list is! List || list.isEmpty) return scaffold;

    var result = scaffold;
    for (final item in list) {
      if (item is! Map) continue;
      final m = Map<String, dynamic>.from(item);
      final date = _parseDate(m['date'] ?? m['day'] ?? m['attendance_date']);
      if (date == null) continue;

      final netWork = _parseDuration(
        seconds: m['net_work_seconds'],
        minutes: m['net_work_minutes'],
        hours: m['net_hours'] ?? m['hours'] ?? m['worked_hours'],
      );
      final totalBreak = _parseDuration(
        seconds: m['total_break_seconds'],
        minutes: m['total_break_minutes'],
        hours: m['break_hours'] ?? m['total_break_hours'],
      );

      result = result.withDay(date, netWork, totalBreak);
    }
    return result;
  }

  static Map<String, dynamic> _unwrap(Map<String, dynamic> json) {
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
