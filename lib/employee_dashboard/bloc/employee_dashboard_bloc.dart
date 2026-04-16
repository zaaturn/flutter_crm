import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'employee_dashboard_event.dart';
import 'employee_dashboard_state.dart';
import '../repository/employee_dashboard_repository.dart';
import 'package:my_app/services/secure_storage_service.dart';
import 'package:my_app/core/error_handler/error_handler.dart';

class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  final EmployeeRepository repo;

  Timer? _pollingTimer;
  Timer? _attendancePollingTimer;
  final SecureStorageService _storage = SecureStorageService();

  EmployeeBloc({required this.repo})
      : super(EmployeeState(loading: true)) {

    on<LoadDashboard>(_onLoadDashboard);
    on<ToggleCheckInEvent>(_onToggleCheckIn);
    on<ToggleBreakEvent>(_onToggleBreak);
    on<StartTaskPolling>(_onStartPolling);
    on<StopTaskPolling>(_onStopPolling);
    on<UpdateTaskStatus>(_onUpdateTaskStatus);
    on<RegisterNotificationDevice>(_onRegisterNotificationDevice);
    on<LogoutEvent>(_onLogout);
  }

  // =========================================================
  // LOAD DASHBOARD
  // =========================================================
  Future<void> _onLoadDashboard(
      LoadDashboard event,
      Emitter<EmployeeState> emit,
      ) async {
    // Never rely on ApiClient().isAuthenticated here (it can be stale right after login).
    // If there is no token, we reset state so we never show the previous user's profile.
    final token = await _storage.readToken();
    if (token == null || token.isEmpty) {
      emit(EmployeeState(loading: false));
      return;
    }

    emit(state.copyWith(loading: true, error: null));

    try {
      final employee = await repo.fetchEmployeeProfile();
      final attendance = await repo.fetchAttendance();
      final tasks = await repo.fetchTasks();
      final sharedItems = await repo.fetchSharedItems();
      final events = await repo.fetchEvents();

      emit(state.copyWith(
        loading: false,
        employee: employee,
        attendance: attendance,
        tasks: tasks,
        sharedItems: sharedItems,
        events: events,
        error: null,
      ));

      _startAttendancePolling(emit);
    } catch (err) {
      emit(state.copyWith(
        loading: false,
        error: ErrorHandler.format(err),
      ));
    }
  }

  void _startAttendancePolling(Emitter<EmployeeState> emit) {
    _attendancePollingTimer?.cancel();
    _attendancePollingTimer = Timer.periodic(
      const Duration(seconds: 45),
          (_) async {
        final token = await _storage.readToken();
        if (token == null || token.isEmpty) {
          _attendancePollingTimer?.cancel();
          _attendancePollingTimer = null;
          return;
        }

        try {
          final attendance = await repo.fetchAttendance();
          emit(state.copyWith(attendance: attendance));
        } catch (err) {
          if (kDebugMode) {
            debugPrint("Attendance refresh error: ${ErrorHandler.format(err)}");
          }
        }
      },
    );
  }

  // =========================================================
  // CHECK IN / OUT
  // =========================================================
  Future<void> _onToggleCheckIn(
      ToggleCheckInEvent event,
      Emitter<EmployeeState> emit,
      ) async {
    final userId = await _storage.readUserId();
    if (userId == null || userId.isEmpty) {
      emit(state.copyWith(error: "Session expired. Please login again."));
      return;
    }

    emit(state.copyWith(loading: true, error: null));

    try {
      final attendance = await repo.toggleCheckIn();

      emit(state.copyWith(
        loading: false,
        attendance: attendance,
        error: null,
      ));
    } catch (err) {
      emit(state.copyWith(
        loading: false,
        error: ErrorHandler.format(err),
      ));
    }
  }

  // =========================================================
  // BREAK
  // =========================================================
  Future<void> _onToggleBreak(
      ToggleBreakEvent event,
      Emitter<EmployeeState> emit,
      ) async {
    final userId = await _storage.readUserId();
    if (userId == null || userId.isEmpty) {
      emit(state.copyWith(error: "Session expired. Please login again."));
      return;
    }

    emit(state.copyWith(loading: true, error: null));

    try {
      final attendance = await repo.toggleBreak();

      emit(state.copyWith(
        loading: false,
        attendance: attendance,
        error: null,
      ));

    } catch (err) {

      emit(state.copyWith(
        loading: false,
        error: ErrorHandler.format(err),
      ));

      add(LoadDashboard());
    }
  }

  // =========================================================
  // TASK POLLING
  // =========================================================
  void _onStartPolling(
      StartTaskPolling event,
      Emitter<EmployeeState> emit,
      ) {

    _pollingTimer?.cancel();

    _pollingTimer = Timer.periodic(
      const Duration(seconds: 12),
          (_) async {
        final token = await _storage.readToken();
        if (token == null || token.isEmpty) {
          _pollingTimer?.cancel();
          _pollingTimer = null;
          return;
        }

        try {
          final tasks = await repo.fetchTasks();

          emit(state.copyWith(tasks: tasks));
        } catch (err) {
          if (kDebugMode) {
            debugPrint("Polling error: ${ErrorHandler.format(err)}");
          }
        }
      },
    );
  }

  // =========================================================
  // STOP POLLING
  // =========================================================
  void _onStopPolling(
      StopTaskPolling event,
      Emitter<EmployeeState> emit,
      ) {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  // =========================================================
  // UPDATE TASK (OPTIMISTIC)
  // =========================================================
  Future<void> _onUpdateTaskStatus(
      UpdateTaskStatus event,
      Emitter<EmployeeState> emit,
      ) async {
    final token = await _storage.readToken();
    if (token == null || token.isEmpty) return;

    final optimisticTasks = state.tasks.map((task) {
      if (task.id == event.taskId) {
        return task.copyWith(status: event.status);
      }
      return task;
    }).toList();

    emit(state.copyWith(tasks: optimisticTasks, error: null));

    try {
      await repo.updateTaskStatus(event.taskId, event.status);
    } catch (err) {
      final token = await _storage.readToken();
      if (token == null || token.isEmpty) return;

      emit(state.copyWith(
        error: ErrorHandler.format(err),
      ));

      add(LoadDashboard());
    }
  }

  // =========================================================
  // REGISTER DEVICE
  // =========================================================
  Future<void> _onRegisterNotificationDevice(
      RegisterNotificationDevice event,
      Emitter<EmployeeState> emit,
      ) async {
    final token = await _storage.readToken();
    if (token == null || token.isEmpty) return;

    try {
      final messaging = FirebaseMessaging.instance;

      await messaging.requestPermission();

      final token = await messaging.getToken(
        vapidKey: kIsWeb
            ? "BDl2RpvxVJ442k-TJpCoAFHH3SLFxClV7Zy71uNq_MfRJPWTzi5qRkCPztfD2sIq--7LHESRCHbIVZO1ACehWhM"
            : null,
      );

      if (token != null) {
        await repo.registerDeviceToken();
        debugPrint("Notification device registered");
      }
    } catch (err) {
      if (kDebugMode) {
        debugPrint("Notification registration failed: ${ErrorHandler.format(err)}");
      }
    }
  }

  // =========================================================
  // LOGOUT
  // =========================================================
  Future<void> _onLogout(
      LogoutEvent event,
      Emitter<EmployeeState> emit,
      ) async {

    _pollingTimer?.cancel();
    _pollingTimer = null;
    _attendancePollingTimer?.cancel();
    _attendancePollingTimer = null;

    await repo.logout();

    emit(EmployeeState(loading: false));
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    _attendancePollingTimer?.cancel();
    return super.close();
  }
}