import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'employee_dashboard_event.dart';
import 'employee_dashboard_state.dart';
import '../repository/employee_dashboard_repository.dart';

class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  final EmployeeRepository repo;

  Timer? _pollingTimer;
  bool _isLoggedOut = false;

  EmployeeBloc({required this.repo})
      : super(EmployeeState(loading: true)) {

    // Dashboard
    on<LoadDashboard>(_onLoadDashboard);

    // Attendance
    on<ToggleCheckInEvent>(_onToggleCheckIn);
    on<ToggleBreakEvent>(_onToggleBreak);

    // Tasks
    on<StartTaskPolling>(_onStartPolling);
    on<StopTaskPolling>(_onStopPolling);
    on<UpdateTaskStatus>(_onUpdateTaskStatus);

    // Notifications
    on<RegisterNotificationDevice>(_onRegisterNotificationDevice);

    // Logout
    on<LogoutEvent>(_onLogout);
  }

  /* ---------------- LOAD DASHBOARD ---------------- */
  Future<void> _onLoadDashboard(
      LoadDashboard event,
      Emitter<EmployeeState> emit,
      ) async {

    if (_isLoggedOut) return;

    emit(state.copyWith(loading: true, error: null));

    try {
      final employee = await repo.fetchEmployeeProfile();
      final attendance = await repo.fetchAttendance();
      final tasks = await repo.fetchTasks();
      final sharedItems = await repo.fetchSharedItems();
      final events = await repo.fetchEvents();

      if (_isLoggedOut) return;

      emit(state.copyWith(
        loading: false,
        employee: employee,
        attendance: attendance,
        tasks: tasks,
        sharedItems: sharedItems,
        events: events,
      ));
    } catch (err) {
      if (_isLoggedOut) return;

      emit(state.copyWith(
        loading: false,
        error: err.toString(),
      ));
    }
  }

  /* ---------------- CHECK IN / OUT ---------------- */
  Future<void> _onToggleCheckIn(
      ToggleCheckInEvent event,
      Emitter<EmployeeState> emit,
      ) async {

    if (_isLoggedOut) return;

    emit(state.copyWith(loading: true, error: null));

    try {
      await repo.toggleCheckIn();
      final attendance = await repo.fetchAttendance();

      emit(state.copyWith(
        loading: false,
        attendance: attendance,
      ));
    } catch (err) {
      emit(state.copyWith(
        loading: false,
        error: err.toString(),
      ));
    }
  }

  /* ---------------- BREAK ---------------- */
  Future<void> _onToggleBreak(
      ToggleBreakEvent event,
      Emitter<EmployeeState> emit,
      ) async {

    if (_isLoggedOut) return;

    emit(state.copyWith(loading: true, error: null));

    try {
      await repo.toggleBreak();
      final attendance = await repo.fetchAttendance();

      emit(state.copyWith(
        loading: false,
        attendance: attendance,
      ));
    } catch (err) {
      emit(state.copyWith(
        loading: false,
        error: err.toString(),
      ));
    }
  }

  /* ---------------- TASK POLLING ---------------- */
  void _onStartPolling(
      StartTaskPolling event,
      Emitter<EmployeeState> emit,
      ) {

    _pollingTimer?.cancel();

    _pollingTimer = Timer.periodic(
      const Duration(seconds: 12),
          (_) async {

        if (_isLoggedOut) {
          _pollingTimer?.cancel();
          return;
        }

        try {
          final tasks = await repo.fetchTasks();

          if (_isLoggedOut) return;

          emit(state.copyWith(tasks: tasks));
        } catch (_) {}
      },
    );
  }

  void _onStopPolling(
      StopTaskPolling event,
      Emitter<EmployeeState> emit,
      ) {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /* ---------------- UPDATE TASK ---------------- */
  Future<void> _onUpdateTaskStatus(
      UpdateTaskStatus event,
      Emitter<EmployeeState> emit,
      ) async {

    if (_isLoggedOut) return;

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
      if (_isLoggedOut) return;
      emit(state.copyWith(error: err.toString()));
      add(LoadDashboard());
    }
  }

  /* ---------------- REGISTER DEVICE ---------------- */
  Future<void> _onRegisterNotificationDevice(
      RegisterNotificationDevice event,
      Emitter<EmployeeState> emit,
      ) async {

    if (_isLoggedOut) return;

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
        debugPrint("✅ Notification device registered");
      }
    } catch (err) {
      debugPrint("❌ Notification registration failed: $err");
    }
  }

  /* ---------------- LOGOUT ---------------- */
  Future<void> _onLogout(
      LogoutEvent event,
      Emitter<EmployeeState> emit,
      ) async {

    _isLoggedOut = true;
    _pollingTimer?.cancel();
    _pollingTimer = null;

    await repo.logout();

    emit(EmployeeState(loading: false));
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }
}
