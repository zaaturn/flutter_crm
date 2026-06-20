class AttendanceSummaryRow {
  final int employeeId;
  final String employeeName;
  final String? employeeCode;
  final String? department;
  final String? start;
  final String? end;
  final String? loginTime;
  final String? logoutTime;
  final int daysPresent;
  final double leaveTakenDays;
  final double totalNetHours;
  final double totalWorkedHours;
  final double totalCappedHours;
  final double capDailyHours;

  const AttendanceSummaryRow({
    required this.employeeId,
    required this.employeeName,
    this.employeeCode,
    this.department,
    this.start,
    this.end,
    this.loginTime,
    this.logoutTime,
    this.daysPresent = 0,
    this.leaveTakenDays = 0,
    this.totalNetHours = 0,
    this.totalWorkedHours = 0,
    this.totalCappedHours = 0,
    this.capDailyHours = 9,
  });

  factory AttendanceSummaryRow.fromJson(Map<String, dynamic> json) {
    return AttendanceSummaryRow(
      employeeId: _int(json['employee_id'] ?? json['id']),
      employeeName:
          (json['employee_name'] ?? json['name'] ?? 'Employee').toString(),
      employeeCode: json['employee_code']?.toString(),
      department: json['department']?.toString(),
      start: json['start']?.toString(),
      end: json['end']?.toString(),
      loginTime: _time(json['login_time'] ?? json['check_in_time'] ?? json['check_in']),
      logoutTime: _time(json['logout_time'] ?? json['check_out_time'] ?? json['check_out']),
      daysPresent: _int(json['days_present']),
      leaveTakenDays: _double(json['leave_taken_days']),
      totalNetHours: _double(json['total_net_hours']),
      totalWorkedHours: _workedHours(json),
      totalCappedHours: _double(json['total_capped_hours']),
      capDailyHours: _double(json['cap_daily_hours'], fallback: 9),
    );
  }

  /// Prefer API `total_worked_hours`; fall back to `total_capped_hours`.
  static double _workedHours(Map<String, dynamic> json) {
    if (json.containsKey('total_worked_hours')) {
      return _double(json['total_worked_hours']);
    }
    return _double(json['total_capped_hours']);
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

  static double _double(dynamic v, {double fallback = 0}) {
    if (v == null) return fallback;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? fallback;
  }
}

class AttendanceSummaryModel {
  final String start;
  final String end;
  final double capDailyHours;
  final List<AttendanceSummaryRow> rows;

  const AttendanceSummaryModel({
    required this.start,
    required this.end,
    this.capDailyHours = 9,
    this.rows = const [],
  });

  int get employeeCount => rows.length;

  double get totalLeaveTaken =>
      rows.fold(0.0, (sum, r) => sum + r.leaveTakenDays);

  double get totalWorkedHours =>
      rows.fold(0.0, (sum, r) => sum + r.totalWorkedHours);

  double get totalCappedHours =>
      rows.fold(0.0, (sum, r) => sum + r.totalCappedHours);

  factory AttendanceSummaryModel.fromJson(Map<String, dynamic> json) {
    final data = _unwrap(json);
    final list = data['rows'] ?? data['results'] ?? data['employees'];
    final rows = list is List
        ? list
            .whereType<Map>()
            .map(
              (e) => AttendanceSummaryRow.fromJson(
                Map<String, dynamic>.from(e),
              ),
            )
            .toList()
        : <AttendanceSummaryRow>[];

    return AttendanceSummaryModel(
      start: (data['start'] ?? '').toString(),
      end: (data['end'] ?? '').toString(),
      capDailyHours: AttendanceSummaryRow._double(
        data['cap_daily_hours'],
        fallback: 9,
      ),
      rows: rows,
    );
  }

  static Map<String, dynamic> _unwrap(Map<String, dynamic> json) {
    final nested = json['data'] ?? json['summary'];
    if (nested is Map) return Map<String, dynamic>.from(nested);
    return json;
  }
}
