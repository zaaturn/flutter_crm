class AttendanceModel {
  final bool isCheckedIn;
  final bool onBreak;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  /// Net working time for today (server truth / live-synced).
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

  /// Recompute net work from check-in so refresh does not lose seconds
  /// when the API only sent whole minutes (or after a slow round-trip).
  AttendanceModel syncedToNow([DateTime? now]) {
    if (!isCheckedIn || checkInTime == null || onBreak) return this;
    final clock = now ?? DateTime.now();
    var net = clock.difference(checkInTime!) - totalBreak;
    if (net.isNegative) net = Duration.zero;
    // Prefer the higher of server baseline and clock so we never jump backward
    // from a slightly-ahead live ticker during the same session.
    if (net < netWork) net = netWork;
    return copyWith(netWork: net);
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

    Duration parseDuration({
      required Map<String, dynamic> map,
      required List<String> secondsKeys,
      required List<String> minutesKeys,
    }) {
      for (final key in secondsKeys) {
        if (!map.containsKey(key) || map[key] == null) continue;
        return Duration(seconds: parseInt(map[key]));
      }
      for (final key in minutesKeys) {
        if (!map.containsKey(key) || map[key] == null) continue;
        return Duration(minutes: parseInt(map[key]));
      }
      return Duration.zero;
    }

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

    final totalBreak = parseDuration(
      map: m,
      secondsKeys: const ['total_break_seconds', 'break_seconds'],
      minutesKeys: const ['total_break_minutes', 'break_minutes'],
    );

    var netWork = parseDuration(
      map: m,
      secondsKeys: const [
        'net_work_seconds',
        'total_worked_seconds',
        'worked_seconds',
      ],
      minutesKeys: const [
        'net_work_minutes',
        'total_worked_minutes',
        'worked_minutes',
      ],
    );

    // If API only sent minutes (legacy), rebuild from check-in for second accuracy.
    if (isCheckedIn &&
        checkInTime != null &&
        !onBreak &&
        !m.containsKey('net_work_seconds') &&
        !m.containsKey('total_worked_seconds') &&
        !m.containsKey('worked_seconds')) {
      var computed = DateTime.now().difference(checkInTime) - totalBreak;
      if (computed.isNegative) computed = Duration.zero;
      netWork = computed;
    }

    return AttendanceModel(
      isCheckedIn: isCheckedIn,
      onBreak: onBreak,
      checkInTime: checkInTime,
      checkOutTime: checkOutTime,
      netWork: netWork,
      totalBreak: totalBreak,
      breakCount: parseInt(m['break_count']),
    ).syncedToNow();
  }
}
