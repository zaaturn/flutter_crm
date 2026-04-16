class AttendanceModel {
  final bool isCheckedIn;
  final bool onBreak;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  /// Net working time for today (server truth).
  final Duration netWork;

  /// Total break time for today (server truth).
  final Duration totalBreak;

  /// How many breaks have been taken today (server truth).
  final int breakCount;

  /// Backwards-compat: previously the UI displayed `totalHours`.
  /// Keep it mapped to net work time so old widgets continue to work.
  Duration get totalHours => netWork;

  AttendanceModel({
    required this.isCheckedIn,
    required this.onBreak,
    this.checkInTime,
    this.checkOutTime,
    required this.netWork,
    required this.totalBreak,
    required this.breakCount,
  });

  AttendanceModel copyWith({
    bool? isCheckedIn,
    bool? onBreak,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    Duration? netWork,
    Duration? totalBreak,
    int? breakCount,
  }) {
    return AttendanceModel(
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
      onBreak: onBreak ?? this.onBreak,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      netWork: netWork ?? this.netWork,
      totalBreak: totalBreak ?? this.totalBreak,
      breakCount: breakCount ?? this.breakCount,
    );
  }

  factory AttendanceModel.fromMap(Map<String, dynamic> m) {
    bool truthy(dynamic v) {
      if (v == null) return false;
      if (v is bool) return v;
      if (v is num) return v != 0;
      final s = v.toString().trim().toLowerCase();
      return s == 'true' || s == '1' || s == 'yes' || s == 'y';
    }

    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v.toLocal();

      try {
        return DateTime.parse(v.toString()).toLocal();
      } catch (_) {
        return null;
      }
    }

    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? 0;
    }

    Duration parseSecondsOrMinutes({
      required dynamic seconds,
      required dynamic minutes,
    }) {
      final s = parseInt(seconds);
      if (s > 0) return Duration(seconds: s);
      final min = parseInt(minutes);
      return Duration(minutes: min);
    }

    final netWork = parseSecondsOrMinutes(
      seconds: m['net_work_seconds'],
      minutes: m['net_work_minutes'],
    );
    final totalBreak = parseSecondsOrMinutes(
      seconds: m['total_break_seconds'],
      minutes: m['total_break_minutes'],
    );

    // Some endpoints may return a partial payload (e.g. break start/end).
    // If `is_checked_in` is missing, infer from check-in/out timestamps.
    final checkInTime = parseDate(m['check_in_time'] ?? m['check_in']);
    final checkOutTime = parseDate(m['check_out_time'] ?? m['check_out']);

    final hasIsCheckedInKey = m.containsKey('is_checked_in') ||
        m.containsKey('checked_in') ||
        m.containsKey('is_checkin') ||
        m.containsKey('checkin');
    final inferredCheckedIn =
        checkInTime != null && checkOutTime == null; // punched in, not out

    final isCheckedIn = hasIsCheckedInKey
        ? truthy(
            m['is_checked_in'] ??
                m['checked_in'] ??
                m['is_checkin'] ??
                m['checkin'],
          )
        : inferredCheckedIn;

    final hasOnBreakKey = m.containsKey('on_break') ||
        m.containsKey('is_on_break') ||
        m.containsKey('break') ||
        m.containsKey('break_time') ||
        m.containsKey('is_break');
    final onBreak = hasOnBreakKey
        ? truthy(
            m['on_break'] ??
                m['is_on_break'] ??
                m['break'] ??
                m['break_time'] ??
                m['is_break'],
          )
        : false;

    return AttendanceModel(
      isCheckedIn: isCheckedIn,
      onBreak: onBreak,
      checkInTime: checkInTime,
      checkOutTime: checkOutTime,
      netWork: netWork,
      totalBreak: totalBreak,
      breakCount: parseInt(m['break_count']),
    );
  }
}