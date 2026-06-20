class WeeklyAttendanceDayRow {
  final int employeeId;
  final String employeeName;
  final String? employeeCode;
  final String? department;
  final DateTime? date;
  final String? weekday;
  final bool onLeave;
  final String? checkIn;
  final String? checkOut;
  final double netHours;
  final double cappedHours;
  final String status;

  const WeeklyAttendanceDayRow({
    required this.employeeId,
    required this.employeeName,
    this.employeeCode,
    this.department,
    this.date,
    this.weekday,
    this.onLeave = false,
    this.checkIn,
    this.checkOut,
    this.netHours = 0,
    this.cappedHours = 0,
    this.status = '',
  });

  factory WeeklyAttendanceDayRow.fromJson(Map<String, dynamic> json) {
    return WeeklyAttendanceDayRow(
      employeeId: _int(json['employee_id'] ?? json['id']),
      employeeName:
          (json['employee_name'] ?? json['name'] ?? 'Employee').toString(),
      employeeCode: json['employee_code']?.toString(),
      department: json['department']?.toString(),
      date: _parseDate(json['date'] ?? json['day']),
      weekday: json['weekday']?.toString(),
      onLeave: json['on_leave'] == true,
      checkIn: _time(
        json['check_in'] ??
            json['check_in_time'] ??
            json['login_time'] ??
            json['punch_in'],
      ),
      checkOut: _time(
        json['check_out'] ??
            json['check_out_time'] ??
            json['logout_time'] ??
            json['punch_out'],
      ),
      netHours: _double(json['net_hours'] ?? json['hours']),
      cappedHours: _dayWorkedHours(json),
      status: (json['status'] ?? '').toString(),
    );
  }

  static double _dayWorkedHours(Map<String, dynamic> json) {
    if (json.containsKey('total_worked_hours')) {
      return _double(json['total_worked_hours']);
    }
    if (json.containsKey('capped_hours')) {
      return _double(json['capped_hours']);
    }
    return _double(json['net_hours'] ?? json['hours']);
  }

  static String? _time(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  static int _int(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static double _double(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    try {
      return DateTime.parse(v.toString()).toLocal();
    } catch (_) {
      return null;
    }
  }
}

class WeeklyAttendanceSummaryRow {
  final int employeeId;
  final String employeeName;
  final String? employeeCode;
  final int daysPresent;
  final double totalNetHours;
  final double totalWorkedHours;
  final double totalCappedHours;

  const WeeklyAttendanceSummaryRow({
    required this.employeeId,
    required this.employeeName,
    this.employeeCode,
    this.daysPresent = 0,
    this.totalNetHours = 0,
    this.totalWorkedHours = 0,
    this.totalCappedHours = 0,
  });

  factory WeeklyAttendanceSummaryRow.fromJson(Map<String, dynamic> json) {
    return WeeklyAttendanceSummaryRow(
      employeeId: _int(json['employee_id'] ?? json['id']),
      employeeName:
          (json['employee_name'] ?? json['name'] ?? 'Employee').toString(),
      employeeCode: json['employee_code']?.toString(),
      daysPresent: _int(json['days_present']),
      totalNetHours: _double(json['total_net_hours']),
      totalWorkedHours: _summaryWorkedHours(json),
      totalCappedHours: _double(json['total_capped_hours']),
    );
  }

  static double _summaryWorkedHours(Map<String, dynamic> json) {
    if (json.containsKey('total_worked_hours')) {
      return _double(json['total_worked_hours']);
    }
    return _double(json['total_capped_hours']);
  }

  static int _int(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static double _double(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}

class WeeklyAttendanceModel {
  final int year;
  final int week;
  final String? weekStart;
  final String? weekEnd;
  final double maxDailyHours;
  final List<WeeklyAttendanceDayRow> dailyRows;
  final List<WeeklyAttendanceSummaryRow> summaryRows;

  const WeeklyAttendanceModel({
    required this.year,
    required this.week,
    this.weekStart,
    this.weekEnd,
    this.maxDailyHours = 9,
    this.dailyRows = const [],
    this.summaryRows = const [],
  });

  List<WeeklyAttendanceDayRow> filteredDailyRows({String? dayKey}) {
    if (dayKey == null || dayKey.isEmpty) return dailyRows;
    return dailyRows.where((r) => _dateKey(r.date) == dayKey).toList();
  }

  static String? _dateKey(DateTime? d) {
    if (d == null) return null;
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  factory WeeklyAttendanceModel.fromJson(
    Map<String, dynamic> json, {
    required int year,
    required int week,
  }) {
    final data = _unwrap(json);
    final dailyList = data['rows'] ?? data['daily_rows'] ?? data['results'];
    final summaryList =
        data['employee_summary'] ?? data['summary'] ?? data['summaries'];

    final dailyRows = dailyList is List
        ? dailyList
            .whereType<Map>()
            .map((e) => WeeklyAttendanceDayRow.fromJson(
                  Map<String, dynamic>.from(e),
                ))
            .toList()
        : <WeeklyAttendanceDayRow>[];

    final summaryRows = summaryList is List
        ? summaryList
            .whereType<Map>()
            .map((e) => WeeklyAttendanceSummaryRow.fromJson(
                  Map<String, dynamic>.from(e),
                ))
            .toList()
        : <WeeklyAttendanceSummaryRow>[];

    return WeeklyAttendanceModel(
      year: _int(data['year']) ?? year,
      week: _int(data['week']) ?? week,
      weekStart: data['week_start']?.toString(),
      weekEnd: data['week_end']?.toString(),
      maxDailyHours: _double(
        data['max_daily_hours'] ??
            data['cap_daily_hours'] ??
            data['cap_hours_per_day'],
      ),
      dailyRows: dailyRows,
      summaryRows: summaryRows,
    );
  }

  static Map<String, dynamic> _unwrap(Map<String, dynamic> json) {
    final nested = json['data'] ?? json['attendance'];
    if (nested is Map) return Map<String, dynamic>.from(nested);
    return json;
  }

  static int? _int(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static double _double(dynamic v) {
    if (v == null) return 9;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 9;
  }
}
