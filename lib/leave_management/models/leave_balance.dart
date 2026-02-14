// lib/features/leave_management/models/leave_balance.dart

import 'leave_type.dart';

class LeaveBalance {
  final int id;
  final int employeeId;
  final LeaveType leaveType;
  final int year;
  final double allocated;
  final double used;

  LeaveBalance({
    required this.id,
    required this.employeeId,
    required this.leaveType,
    required this.year,
    required this.allocated,
    required this.used,
  });

  double get remaining => allocated - used;

  double get percentageUsed => (used / allocated * 100).clamp(0, 100);

  bool get isLowBalance => remaining < (allocated * 0.25);

  factory LeaveBalance.fromJson(Map<String, dynamic> json) {
    return LeaveBalance(
      id: json['id'],
      employeeId: json['employee'],
      leaveType: LeaveType.fromJson(json['leave_type']),
      year: json['year'],
      allocated: double.parse(json['allocated'].toString()),
      used: double.parse(json['used'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee': employeeId,
      'leave_type': leaveType.id,
      'year': year,
      'allocated': allocated,
      'used': used,
    };
  }
}