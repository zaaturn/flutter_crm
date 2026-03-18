import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/leave_management/block/leave_event.dart';
import 'package:my_app/leave_management/block/leave_state.dart';
import 'package:my_app/leave_management/models/leave_request.dart';
import '../services/leave_api_services.dart';

class LeaveBloc extends Bloc<LeaveEvent, LeaveState> {
  final LeaveApiService apiService;


  List<LeaveRequest> _cachedLeaves = [];


  String? _lastStatus;
  DateTime? _lastStartDate;
  DateTime? _lastEndDate;

  LeaveBloc(this.apiService) : super(LeaveInitial()) {
    on<LoadLeaveTypes>(_onLoadLeaveTypes);
    on<LoadLeaveBalances>(_onLoadLeaveBalances);
    on<LoadMyLeaves>(_onLoadMyLeaves);
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
    emit(LeaveTypesLoading());
    try {
      final leaveTypes = await apiService.getLeaveTypes();
      emit(LeaveTypesLoaded(leaveTypes));
    } catch (e) {
      emit(LeaveError(_extractErrorMessage(e)));
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
      emit(LeaveError(_extractErrorMessage(e)));
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

  // ================= PENDING LEAVES =================
  Future<void> _onLoadPendingLeaves(
      LoadPendingLeaves event,
      Emitter<LeaveState> emit,
      ) async {
    emit(PendingLeavesLoading());
    try {
      final leaves = await apiService.getPendingLeaves();
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
      );

      emit(LeaveActionSuccess('Leave applied successfully'));

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

  // ================= UPDATE LEAVE =================
  Future<void> _onUpdateLeave(
      UpdateLeave event,
      Emitter<LeaveState> emit,
      ) async {
    emit(LeaveSubmitting());
    try {
      await apiService.updateLeave(
        leaveId: event.leaveId,
        leaveTypeId: event.leaveTypeId,
        startDate: event.startDate,
        endDate: event.endDate,
        reason: event.reason,
      );

      emit(LeaveActionSuccess('Leave updated successfully'));

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