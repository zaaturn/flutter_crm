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
  const LoadLeaveBalances();
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

// ================= APPLY LEAVE (UPDATED) =================

class ApplyLeave extends LeaveEvent {
  final int leaveTypeId;
  final DateTime startDate;
  final DateTime endDate;
  final int approverId;
  final String? reason;

  const ApplyLeave({
    required this.leaveTypeId,
    required this.startDate,
    required this.endDate,
    required this.approverId,
    this.reason,
  });

  @override
  List<Object?> get props => [
    leaveTypeId,
    startDate,
    endDate,
    approverId,
    reason,
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
