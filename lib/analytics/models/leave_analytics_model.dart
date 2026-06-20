class OnLeaveTodayEmployee {
  final int employeeId;
  final String employeeName;
  final String? employeeCode;
  final String? leaveType;
  final String startDate;
  final String endDate;
  final double totalDays;

  const OnLeaveTodayEmployee({
    required this.employeeId,
    required this.employeeName,
    this.employeeCode,
    this.leaveType,
    required this.startDate,
    required this.endDate,
    this.totalDays = 0,
  });

  factory OnLeaveTodayEmployee.fromJson(Map<String, dynamic> json) {
    return OnLeaveTodayEmployee(
      employeeId: _int(json['employee_id'] ?? json['id']),
      employeeName:
          (json['employee_name'] ?? json['name'] ?? 'Employee').toString(),
      employeeCode: json['employee_code']?.toString(),
      leaveType: json['leave_type']?.toString(),
      startDate: (json['start_date'] ?? '').toString(),
      endDate: (json['end_date'] ?? '').toString(),
      totalDays: _double(json['total_days']),
    );
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

class LeaveRecordRow {
  final int id;
  final int employeeId;
  final String employeeName;
  final String? employeeCode;
  final String? leaveType;
  final String? leaveTypeCode;
  final String startDate;
  final String endDate;
  final String duration;
  final double totalDays;
  final String status;
  final String reason;
  final String? appliedAt;

  const LeaveRecordRow({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    this.employeeCode,
    this.leaveType,
    this.leaveTypeCode,
    required this.startDate,
    required this.endDate,
    this.duration = 'FULL',
    this.totalDays = 0,
    this.status = '',
    this.reason = '',
    this.appliedAt,
  });

  factory LeaveRecordRow.fromJson(Map<String, dynamic> json) {
    return LeaveRecordRow(
      id: _int(json['id']),
      employeeId: _int(json['employee_id'] ?? json['id']),
      employeeName:
          (json['employee_name'] ?? json['name'] ?? 'Employee').toString(),
      employeeCode: json['employee_code']?.toString(),
      leaveType: json['leave_type']?.toString(),
      leaveTypeCode: json['leave_type_code']?.toString(),
      startDate: (json['start_date'] ?? '').toString(),
      endDate: (json['end_date'] ?? '').toString(),
      duration: (json['duration'] ?? 'FULL').toString(),
      totalDays: _double(json['total_days']),
      status: (json['status'] ?? '').toString(),
      reason: (json['reason'] ?? '').toString(),
      appliedAt: json['applied_at']?.toString(),
    );
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

class LeaveAnalyticsResponse {
  final int year;
  final int month;
  final String period;
  final int pending;
  final int approved;
  final int rejected;
  final int cancelled;
  final int onLeaveToday;
  final List<OnLeaveTodayEmployee> onLeaveTodayEmployees;
  final List<LeaveRecordRow> records;
  final Map<String, List<LeaveRecordRow>> byStatus;

  const LeaveAnalyticsResponse({
    required this.year,
    required this.month,
    required this.period,
    this.pending = 0,
    this.approved = 0,
    this.rejected = 0,
    this.cancelled = 0,
    this.onLeaveToday = 0,
    this.onLeaveTodayEmployees = const [],
    this.records = const [],
    this.byStatus = const {},
  });

  factory LeaveAnalyticsResponse.fromJson(
    Map<String, dynamic> json, {
    int? year,
    int? month,
  }) {
    final data = _unwrap(json);
    final now = DateTime.now();

    final onLeaveList = data['on_leave_today_employees'];
    final onLeaveTodayEmployees = onLeaveList is List
        ? onLeaveList
            .whereType<Map>()
            .map(
              (e) => OnLeaveTodayEmployee.fromJson(
                Map<String, dynamic>.from(e),
              ),
            )
            .toList()
        : <OnLeaveTodayEmployee>[];

    final recordsList = data['records'];
    final records = recordsList is List
        ? recordsList
            .whereType<Map>()
            .map(
              (e) => LeaveRecordRow.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList()
        : <LeaveRecordRow>[];

    final byStatusRaw = data['by_status'];
    final byStatus = <String, List<LeaveRecordRow>>{};
    if (byStatusRaw is Map) {
      for (final entry in byStatusRaw.entries) {
        final list = entry.value;
        if (list is List) {
          byStatus[entry.key.toString()] = list
              .whereType<Map>()
              .map(
                (e) => LeaveRecordRow.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList();
        }
      }
    }

    return LeaveAnalyticsResponse(
      year: _int(data['year']) ?? year ?? now.year,
      month: _int(data['month']) ?? month ?? now.month,
      period: (data['period'] ?? '').toString(),
      pending: _int(data['pending']) ?? 0,
      approved: _int(data['approved']) ?? 0,
      rejected: _int(data['rejected']) ?? 0,
      cancelled: _int(data['cancelled']) ?? 0,
      onLeaveToday: _int(data['on_leave_today']) ?? 0,
      onLeaveTodayEmployees: onLeaveTodayEmployees,
      records: records,
      byStatus: byStatus,
    );
  }

  static Map<String, dynamic> _unwrap(Map<String, dynamic> json) {
    final nested = json['data'] ?? json['leave'];
    if (nested is Map) return Map<String, dynamic>.from(nested);
    return json;
  }

  static int? _int(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.round();
    return int.tryParse(v.toString());
  }
}
