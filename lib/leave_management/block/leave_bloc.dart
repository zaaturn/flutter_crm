import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/leave_api_services.dart';
import 'leave_event.dart';
import 'leave_state.dart';

class LeaveBloc extends Bloc<LeaveEvent, LeaveState> {
  final LeaveApiService apiService;

  LeaveBloc(this.apiService) : super(LeaveInitial()) {
    on<LoadLeaveTypes>(_onLoadLeaveTypes);
    on<LoadLeaveBalances>(_onLoadLeaveBalances);
    on<LoadMyLeaves>(_onLoadMyLeaves);
    on<LoadPendingLeaves>(_onLoadPendingLeaves);
    on<ApplyLeave>(_onApplyLeave);
    on<ApproveLeaveEvent>(_onApproveLeave);
    on<RejectLeaveEvent>(_onRejectLeave);
    on<CancelLeaveEvent>(_onCancelLeave);
  }

  // ================= LEAVE TYPES =================
  Future<void> _onLoadLeaveTypes(
      LoadLeaveTypes event,
      Emitter<LeaveState> emit,
      ) async {
    emit(LeaveTypesLoading());
    try {
      final leaveTypes = await apiService.getLeaveTypes();
      emit(LeaveTypesLoaded(leaveTypes));
    } catch (e) {
      emit(LeaveError(e.toString()));
    }
  }

  // ================= LEAVE BALANCES =================
  Future<void> _onLoadLeaveBalances(
      LoadLeaveBalances event,
      Emitter<LeaveState> emit,
      ) async {
    emit(LeaveBalancesLoading());
    try {
      final balances = await apiService.getMyLeaveBalances();
      emit(LeaveBalancesLoaded(balances));
    } catch (e) {
      emit(LeaveError(e.toString()));
    }
  }

  // ================= MY LEAVES =================
  Future<void> _onLoadMyLeaves(
      LoadMyLeaves event,
      Emitter<LeaveState> emit,
      ) async {
    emit(MyLeavesLoading());
    try {
      final leaves = await apiService.getMyLeaves(
        status: event.status,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(MyLeavesLoaded(leaves));
    } catch (e) {
      emit(LeaveError(e.toString()));
    }
  }

  // ================= PENDING LEAVES (ADMIN) =================
  Future<void> _onLoadPendingLeaves(
      LoadPendingLeaves event,
      Emitter<LeaveState> emit,
      ) async {
    emit(PendingLeavesLoading());
    try {
      final leaves = await apiService.getPendingLeaves();
      emit(PendingLeavesLoaded(leaves));
    } catch (e) {
      emit(LeaveError(e.toString()));
    }
  }

  // ================= APPLY LEAVE =================
  Future<void> _onApplyLeave(
      ApplyLeave event,
      Emitter<LeaveState> emit,
      ) async {
    emit(LeaveSubmitting());
    try {
      await apiService.applyLeave(
        leaveTypeId: event.leaveTypeId,
        startDate: event.startDate,
        endDate: event.endDate,
        approverId: event.approverId,
        reason: event.reason,
      );

      emit(LeaveActionSuccess('Leave applied successfully'));

      // Optional refresh
      add(const LoadMyLeaves());
    } catch (e) {
      emit(LeaveError(e.toString()));
    }
  }

  // ================= APPROVE LEAVE =================
  Future<void> _onApproveLeave(
      ApproveLeaveEvent event,
      Emitter<LeaveState> emit,
      ) async {
    emit(LeaveSubmitting());
    try {
      await apiService.approveLeave(
        event.leaveId,
        comment: event.comment,
      );

      emit(LeaveActionSuccess('Leave approved successfully'));

      add(const LoadPendingLeaves());
    } catch (e) {
      emit(LeaveError(e.toString()));
    }
  }

  // ================= REJECT LEAVE =================
  Future<void> _onRejectLeave(
      RejectLeaveEvent event,
      Emitter<LeaveState> emit,
      ) async {
    emit(LeaveSubmitting());
    try {
      await apiService.rejectLeave(
        event.leaveId,
        comment: event.comment,
      );

      emit(LeaveActionSuccess('Leave rejected successfully'));

      add(const LoadPendingLeaves());
    } catch (e) {
      emit(LeaveError(e.toString()));
    }
  }

  // ================= CANCEL LEAVE =================
  Future<void> _onCancelLeave(
      CancelLeaveEvent event,
      Emitter<LeaveState> emit,
      ) async {
    emit(LeaveSubmitting());
    try {
      await apiService.cancelLeave(event.leaveId);

      emit(LeaveActionSuccess('Leave cancelled successfully'));

      add(const LoadMyLeaves());
    } catch (e) {
      emit(LeaveError(e.toString()));
    }
  }
}
