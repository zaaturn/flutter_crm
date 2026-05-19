import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/leave_management/block/leave_dashboard_event.dart';
import 'package:my_app/leave_management/block/leave_dashboard_state.dart';
import 'package:my_app/leave_management/services/leave_api_services.dart';
import 'package:my_app/leave_management/models/leave_request.dart';

class LeaveDashboardBloc
    extends Bloc<LeaveDashboardEvent, LeaveDashboardState> {
  final LeaveApiService repository;

  LeaveDashboardBloc(this.repository)
      : super(const LeaveDashboardState()) {
    on<FetchDashboardCounts>(_fetchDashboard);
    on<RefreshDashboardCounts>(_refreshDashboard);
    on<FetchAllLeaves>(_fetchAllLeaves);
    on<FilterLeaves>(_filterLeaves);
    on<DeleteLeaveEvent>(_deleteLeave);
    on<ApproveLeaveEvent>(_approveLeave);
    on<RejectLeaveEvent>(_rejectLeave);
    on<ClearMessage>(_clearMessage);
  }

  // Helper method to filter leaves based on status
  List<LeaveRequest> _applyCurrentFilter(List<LeaveRequest> leaves, String status) {
    if (status.toLowerCase() == "all") return leaves;
    return leaves.where((leave) {
      return (leave.status.trim().toLowerCase()) == status.toLowerCase().trim();
    }).toList();
  }

  // ===============================
  // FETCH DASHBOARD COUNTS
  // ===============================
  Future<void> _fetchDashboard(
      FetchDashboardCounts event,
      Emitter<LeaveDashboardState> emit,
      ) async {
    try {
      emit(state.copyWith(isLoading: true, clearError: true));
      final data = await repository.getDashboardCounts();
      emit(state.copyWith(
        pending: data.pending,
        approved: data.approved,
        rejected: data.rejected,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: "Failed to load dashboard",
      ));
    }
  }

  // ===============================
  // REFRESH COUNTS
  // ===============================
  Future<void> _refreshDashboard(
      RefreshDashboardCounts event,
      Emitter<LeaveDashboardState> emit,
      ) async {
    try {
      final data = await repository.getDashboardCounts();
      emit(state.copyWith(
        pending: data.pending,
        approved: data.approved,
        rejected: data.rejected,
      ));
    } catch (e) {
      // Background refresh failures are usually silent
    }
  }

  // ===============================
  // FETCH ALL LEAVES
  // ===============================
  Future<void> _fetchAllLeaves(
      FetchAllLeaves event,
      Emitter<LeaveDashboardState> emit,
      ) async {
    try {
      emit(state.copyWith(isLoading: true, clearError: true));
      final List<LeaveRequest> leaves = await repository.getAllLeaves();
      emit(state.copyWith(
        isLoading: false,
        allLeaves: leaves,
        filteredLeaves: _applyCurrentFilter(leaves, state.selectedFilter),
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: "Failed to fetch leaves",
      ));
    }
  }

  // ===============================
  // FILTER LEAVES
  // ===============================
  void _filterLeaves(
      FilterLeaves event,
      Emitter<LeaveDashboardState> emit,
      ) {
    final filtered = _applyCurrentFilter(state.allLeaves, event.status);
    emit(state.copyWith(
      filteredLeaves: filtered,
      selectedFilter: event.status,
    ));
  }

  // ===============================
  // APPROVE LEAVE
  // ===============================
  Future<void> _approveLeave(
      ApproveLeaveEvent event,
      Emitter<LeaveDashboardState> emit,
      ) async {
    try {
      // Set processing ID to show spinner on the specific button
      emit(state.copyWith(processingId: event.leaveId, clearError: true));

      await repository.approveLeave(event.leaveId);

      final updatedLeaves = state.allLeaves.map((l) {
        return l.id == event.leaveId ? l.copyWith(status: 'APPROVED') : l;
      }).toList();

      emit(state.copyWith(
        allLeaves: updatedLeaves,
        filteredLeaves: _applyCurrentFilter(updatedLeaves, state.selectedFilter),
        successMessage: "Leave approved successfully!",
        clearProcessingId: true, // Remove spinner
      ));

      add(RefreshDashboardCounts());
    } catch (e) {
      emit(state.copyWith(
        error: "Failed to approve leave",
        clearProcessingId: true,
      ));
    }
  }

  // ===============================
  // REJECT LEAVE
  // ===============================
  Future<void> _rejectLeave(
      RejectLeaveEvent event,
      Emitter<LeaveDashboardState> emit,
      ) async {
    try {
      emit(state.copyWith(processingId: event.leaveId, clearError: true));

      await repository.rejectLeave(event.leaveId);

      final updatedLeaves = state.allLeaves.map((l) {
        return l.id == event.leaveId ? l.copyWith(status: 'REJECTED') : l;
      }).toList();

      emit(state.copyWith(
        allLeaves: updatedLeaves,
        filteredLeaves: _applyCurrentFilter(updatedLeaves, state.selectedFilter),
        successMessage: "Leave rejected successfully",
        clearProcessingId: true,
      ));

      add(RefreshDashboardCounts());
    } catch (e) {
      emit(state.copyWith(
        error: "Failed to reject leave",
        clearProcessingId: true,
      ));
    }
  }

  // ===============================
  // DELETE LEAVE
  // ===============================
  Future<void> _deleteLeave(
      DeleteLeaveEvent event,
      Emitter<LeaveDashboardState> emit,
      ) async {
    try {
      emit(state.copyWith(processingId: event.leaveId, clearError: true));

      await repository.deleteLeave(event.leaveId);

      final updatedLeaves = state.allLeaves
          .where((l) => l.id != event.leaveId)
          .toList();

      emit(state.copyWith(
        allLeaves: updatedLeaves,
        filteredLeaves: _applyCurrentFilter(updatedLeaves, state.selectedFilter),
        successMessage: "Leave deleted successfully",
        clearProcessingId: true,
      ));

      add(RefreshDashboardCounts());
    } catch (e) {
      emit(state.copyWith(
        error: "Delete failed: ${e.toString()}",
        clearProcessingId: true,
      ));
    }
  }

  // ===============================
  // CLEAR MESSAGE
  // ===============================
  void _clearMessage(
      ClearMessage event,
      Emitter<LeaveDashboardState> emit,
      ) {
    emit(state.copyWith(clearSuccess: true));
  }
}