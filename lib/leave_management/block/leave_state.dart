import '../models/leave_type.dart';
import '../models/leave_balance_response.dart';
import '../models/leave_request.dart';

/// Base state
abstract class LeaveState {}

/// Initial
class LeaveInitial extends LeaveState {}

/// ================= LOADING STATES =================
/// Each responsibility gets its own loading state

class LeaveTypesLoading extends LeaveState {}

class LeaveBalancesLoading extends LeaveState {}

class MyLeavesLoading extends LeaveState {}

class PendingLeavesLoading extends LeaveState {}

class LeaveSubmitting extends LeaveState {}

/// ================= ERROR =================

class LeaveError extends LeaveState {
  final String message;
  LeaveError(this.message);
}

/// ================= SUCCESS / DATA =================

class LeaveTypesLoaded extends LeaveState {
  final List<LeaveType> leaveTypes;
  LeaveTypesLoaded(this.leaveTypes);
}

class LeaveBalancesLoaded extends LeaveState {
  final LeaveBalanceResponse response;
  LeaveBalancesLoaded(this.response);
}

class MyLeavesLoaded extends LeaveState {
  final List<LeaveRequest> leaves;
  MyLeavesLoaded(this.leaves);
}

class PendingLeavesLoaded extends LeaveState {
  final List<LeaveRequest> leaves;
  PendingLeavesLoaded(this.leaves);
}

/// Generic success for actions (e.g. apply / update leave).
class LeaveActionSuccess extends LeaveState {
  final String message;
  /// Present when PATCH update returns `response['leave']`.
  final LeaveRequest? updatedLeave;
  LeaveActionSuccess(this.message, [this.updatedLeave]);
}

class LeaveDetailsLoaded extends LeaveState {
  final LeaveRequest leave;
  LeaveDetailsLoaded(this.leave);
}