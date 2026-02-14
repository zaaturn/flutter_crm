// lib/features/leave_management/models/leave_request.dart

import 'leave_type.dart';

class LeaveRequest {
  final int? id;
  final int employeeId;
  final String? employeeName;

  final LeaveType? leaveType;
  final String? leaveTypeName;

  final DateTime startDate;
  final DateTime endDate;
  final String duration;
  final double totalDays;
  final String reason;
  final String status;
  final DateTime appliedAt;
  final int? reviewedBy;
  final String? reviewedByName;
  final DateTime? reviewedAt;
  final String? reviewComment;

  LeaveRequest({
    this.id,
    required this.employeeId,
    this.employeeName,
    this.leaveType,
    this.leaveTypeName,
    required this.startDate,
    required this.endDate,
    required this.duration,
    required this.totalDays,
    required this.reason,
    required this.status,
    required this.appliedAt,
    this.reviewedBy,
    this.reviewedByName,
    this.reviewedAt,
    this.reviewComment,
  });

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    final dynamic employeeField = json['employee'];
    final dynamic leaveTypeField = json['leave_type'];

    LeaveType? parsedLeaveType;
    String? parsedLeaveTypeName;

    if (leaveTypeField is Map<String, dynamic>) {
      parsedLeaveType = LeaveType.fromJson(leaveTypeField);
      parsedLeaveTypeName = leaveTypeField['name'];
    } else if (leaveTypeField is String) {
      parsedLeaveTypeName = leaveTypeField;
    }

    return LeaveRequest(
      id: json['id'],
      employeeId: employeeField is int ? employeeField : 0,
      employeeName:
      employeeField is String ? employeeField : json['employee_name'],

      leaveType: parsedLeaveType,
      leaveTypeName: parsedLeaveTypeName,

      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      duration: json['duration'] ?? 'FULL',
      totalDays: double.parse(
        (json['total_days'] ?? json['requested_days'] ?? 0).toString(),
      ),
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'PENDING',
      appliedAt: json['applied_at'] != null
          ? DateTime.parse(json['applied_at'])
          : DateTime.now(),

      reviewedBy: json['reviewed_by'],
      reviewedByName: json['reviewed_by_name'],
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'])
          : null,
      reviewComment: json['review_comment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'employee': employeeId,
      'leave_type': leaveType?.id,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'duration': duration,
      'total_days': totalDays,
      'reason': reason,
      'status': status,
    };
  }

  // ---------- UI HELPERS ----------

  String get displayLeaveType =>
      leaveTypeName ?? leaveType?.name ?? 'Leave';

  String get statusLabel {
    switch (status) {
      case 'APPROVED':
        return 'Approved';
      case 'REJECTED':
        return 'Rejected';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return 'Pending';
    }
  }

  bool get isPending => status == 'PENDING';
  bool get isApproved => status == 'APPROVED';
  bool get isRejected => status == 'REJECTED';
  bool get isCancelled => status == 'CANCELLED';

  int get durationInDays => endDate.difference(startDate).inDays + 1;
}
