import 'dart:async';
import 'dart:collection';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/leave_management/block/leave_event.dart';
import 'package:my_app/leave_management/block/leave_state.dart';
import 'package:my_app/leave_management/models/leave_request.dart';
import 'package:my_app/leave_management/models/leave_balance_response.dart';
import '../services/leave_api_services.dart';

class LeaveBloc extends Bloc<LeaveEvent, LeaveState> {
  final LeaveApiService apiService;


  List<LeaveRequest> _cachedLeaves = [];
  LeaveBalanceResponse? _cachedBalances;

  /// Last successful my-leaves list (for UI when current [state] is not [MyLeavesLoaded]).
  List<LeaveRequest> get myLeavesSnapshot =>
      UnmodifiableListView<LeaveRequest>(_cachedLeaves);

  /// Last successful balance response (for UI when state is not [LeaveBalancesLoaded]).
  LeaveBalanceResponse? get balanceSnapshot => _cachedBalances;


  String? _lastStatus;
  DateTime? _lastStartDate;
  DateTime? _lastEndDate;

  LeaveBloc(this.apiService) : super(LeaveInitial()) {
    on<LoadLeaveTypes>(_onLoadLeaveTypes);
    on<LoadLeaveBalances>(_onLoadLeaveBalances);
    on<LoadMyLeaves>(
      _onLoadMyLeaves,
      transformer: (events, mapper) => events.asyncExpand(mapper),
    );
    on<LoadPendingLeaves>(_onLoadPendingLeaves);
    on<ApplyLeave>(_onApplyLeave);
    on<UpdateLeave>(_onUpdateLeave);
    on<ApproveLeaveEvent>(_onApproveLeave);
    on<RejectLeaveEvent>(_onRejectLeave);
    on<CancelLeaveEvent>(_onCancelLeave);
  }

  // ================= COMMON ERROR HANDLER =================
  String _extractErrorMessage(Object error) {
    final message = error.toString();
    if (message.startsWith("Exception: ")) {
      return message.replaceFirst("Exception: ", "");
    }
    return message;
  }

  // ================= LEAVE TYPES =================
  Future<void> _onLoadLeaveTypes(
      LoadLeaveTypes event,
      Emitter<LeaveState> emit,
      ) async {
    // Do not emit LeaveTypesLoading — it replaced MyLeavesLoaded and made
    // dashboards show 0 pending while types were fetching.
    try {
      final leaveTypes = await apiService.getLeaveTypes();
      emit(LeaveTypesLoaded(leaveTypes));
      if (_cachedLeaves.isNotEmpty) {
        emit(MyLeavesLoaded(_cachedLeaves));
      }
    } catch (e) {
      emit(LeaveError(_extractErrorMessage(e)));
    }
  }

  // ================= LEAVE BALANCES =================
  Future<void> _onLoadLeaveBalances(
      LoadLeaveBalances event,
      Emitter<LeaveState> emit,
      ) async {
    if (_cachedBalances == null) {
      emit(LeaveBalancesLoading());
    }
    try {
      final response = await apiService.fetchMyLeaveBalances(year: event.year);
      _cachedBalances = response;
      emit(LeaveBalancesLoaded(response));
      if (_cachedLeaves.isNotEmpty) {
        emit(MyLeavesLoaded(_cachedLeaves));
      }
    } catch (e) {
      if (_cachedBalances != null) {
        emit(LeaveBalancesLoaded(_cachedBalances!));
      } else {
        emit(LeaveError(_extractErrorMessage(e)));
      }
    }
  }

  // ================= MY LEAVES =================
  Future<void> _onLoadMyLeaves(
      LoadMyLeaves event,
      Emitter<LeaveState> emit,
      ) async {

    if (state is MyLeavesLoading) return;


    _lastStatus = event.status;
    _lastStartDate = event.startDate;
    _lastEndDate = event.endDate;


    if (_cachedLeaves.isEmpty) {
      emit(MyLeavesLoading());
    } else {
      emit(MyLeavesLoaded(_cachedLeaves));
    }

    try {
      final leaves = await apiService.getMyLeaves(
        status: event.status,
        startDate: event.startDate,
        endDate: event.endDate,
      );

      _cachedLeaves = leaves;

      emit(MyLeavesLoaded(leaves));
    } catch (e) {
      if (_cachedLeaves.isNotEmpty) {
        emit(MyLeavesLoaded(_cachedLeaves));
      } else {
        emit(LeaveError(_extractErrorMessage(e)));
      }
    }
  }

  // ================= ADMIN LEAVE QUEUE (all statuses) =================
  /// [LoadPendingLeaves] loads the **admin** leave list used by approval UIs.
  /// Uses `/api/leaves/all/` (same as desktop) so pending / approved / rejected
  /// filters work; `/api/leaves/pending/` only returned open requests.
  Future<void> _onLoadPendingLeaves(
      LoadPendingLeaves event,
      Emitter<LeaveState> emit,
      ) async {
    emit(PendingLeavesLoading());
    try {
      final leaves = await apiService.getAllLeaves();
      emit(PendingLeavesLoaded(leaves));
    } catch (e) {
      emit(LeaveError(_extractErrorMessage(e)));
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
        reason: event.reason,
        duration: event.duration,
      );

      emit(LeaveActionSuccess('Leave applied successfully'));

      await Future.delayed(const Duration(milliseconds: 300));


      add(LoadMyLeaves(
        status: _lastStatus,
        startDate: _lastStartDate,
        endDate: _lastEndDate,
      ));
      add(const LoadLeaveBalances());
    } catch (e) {
      emit(LeaveError(_extractErrorMessage(e)));
    }
  }

  // ================= UPDATE LEAVE =================
  Future<void> _onUpdateLeave(
      UpdateLeave event,
      Emitter<LeaveState> emit,
      ) async {
    emit(LeaveSubmitting());
    try {
      final result = await apiService.updateLeave(
        leaveId: event.leaveId,
        leaveTypeId: event.leaveTypeId,
        startDate: event.startDate,
        endDate: event.endDate,
        reason: event.reason,
        duration: event.duration,
      );

      emit(LeaveActionSuccess(result.detail, result.leave));

      await Future.delayed(const Duration(milliseconds: 300));

      add(LoadMyLeaves(
        status: _lastStatus,
        startDate: _lastStartDate,
        endDate: _lastEndDate,
      ));
    } catch (e) {
      emit(LeaveError(_extractErrorMessage(e)));
    }
  }

  // ================= APPROVE =================
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

      await Future.delayed(const Duration(milliseconds: 300));

      add(const LoadPendingLeaves());
    } catch (e) {
      emit(LeaveError(_extractErrorMessage(e)));
    }
  }

  // ================= REJECT =================
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

      await Future.delayed(const Duration(milliseconds: 300));

      add(const LoadPendingLeaves());
    } catch (e) {
      emit(LeaveError(_extractErrorMessage(e)));
    }
  }

  // ================= CANCEL =================
  Future<void> _onCancelLeave(
      CancelLeaveEvent event,
      Emitter<LeaveState> emit,
      ) async {
    emit(LeaveSubmitting());
    try {
      await apiService.cancelLeave(event.leaveId);

      emit(LeaveActionSuccess('Leave cancelled successfully'));

      await Future.delayed(const Duration(milliseconds: 300));

      add(LoadMyLeaves(
        status: _lastStatus,
        startDate: _lastStartDate,
        endDate: _lastEndDate,
      ));
    } catch (e) {
      emit(LeaveError(_extractErrorMessage(e)));
    }
  }
}