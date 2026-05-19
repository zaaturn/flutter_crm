abstract class LeaveDashboardEvent {}

// ===============================
// DASHBOARD & LIST FETCHING
// ===============================
class FetchDashboardCounts extends LeaveDashboardEvent {}

class RefreshDashboardCounts extends LeaveDashboardEvent {}

class FetchAllLeaves extends LeaveDashboardEvent {}

// ===============================
// FILTERING
// ===============================
class FilterLeaves extends LeaveDashboardEvent {
  final String status;
  FilterLeaves(this.status);
}

// ===============================
// LEAVE ACTIONS (CRUD)
// ===============================
class DeleteLeaveEvent extends LeaveDashboardEvent {
  final int leaveId;
  DeleteLeaveEvent(this.leaveId);
}


class ApproveLeaveEvent extends LeaveDashboardEvent {
  final int leaveId;
  ApproveLeaveEvent({required this.leaveId});
}


class RejectLeaveEvent extends LeaveDashboardEvent {
  final int leaveId;
  RejectLeaveEvent({required this.leaveId});
}

// ===============================
// UTILITY
// ===============================

class ClearMessage extends LeaveDashboardEvent {}