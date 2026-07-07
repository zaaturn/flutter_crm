import 'package:equatable/equatable.dart';

abstract class LeaveEvent extends Equatable {
  const LeaveEvent();

  @override
  List<Object?> get props => [];
}

// ================= LOAD EVENTS =================

class LoadLeaveTypes extends LeaveEvent {
  const LoadLeaveTypes();
}

class LoadLeaveBalances extends LeaveEvent {
  final int? year;

  const LoadLeaveBalances({this.year});

  @override
  List<Object?> get props => [year];
}

class LoadMyLeaves extends LeaveEvent {
  final String? status;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadMyLeaves({
    this.status,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [status, startDate, endDate];
}

class LoadPendingLeaves extends LeaveEvent {
  const LoadPendingLeaves();
}

// ================= APPLY LEAVE =================

class ApplyLeave extends LeaveEvent {
  final int leaveTypeId;
  final DateTime startDate;
  final DateTime endDate;
  final String? reason;
  final String duration;

  const ApplyLeave({
    required this.leaveTypeId,
    required this.startDate,
    required this.endDate,
    this.reason,
    this.duration = 'FULL',
  });

  @override
  List<Object?> get props => [
    leaveTypeId,
    startDate,
    endDate,
    reason,
    duration,
  ];
}

// ================= ADMIN ACTIONS =================

class ApproveLeaveEvent extends LeaveEvent {
  final int leaveId;
  final String? comment;

  const ApproveLeaveEvent({
    required this.leaveId,
    this.comment,
  });

  @override
  List<Object?> get props => [leaveId, comment];
}

class RejectLeaveEvent extends LeaveEvent {
  final int leaveId;
  final String? comment;

  const RejectLeaveEvent({
    required this.leaveId,
    this.comment,
  });

  @override
  List<Object?> get props => [leaveId, comment];
}

class CancelLeaveEvent extends LeaveEvent {
  final int leaveId;

  const CancelLeaveEvent({
    required this.leaveId,
  });

  @override
  List<Object?> get props => [leaveId];
}

// ================= UPDATE LEAVE =================

class UpdateLeave extends LeaveEvent {
  final int leaveId;
  final int leaveTypeId;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final String duration;

  const UpdateLeave({
    required this.leaveId,
    required this.leaveTypeId,
    required this.startDate,
    required this.endDate,
    required this.reason,
    this.duration = 'FULL',
  });

  @override
  List<Object?> get props => [
    leaveId,
    leaveTypeId,
    startDate,
    endDate,
    reason,
    duration,
  ];
}