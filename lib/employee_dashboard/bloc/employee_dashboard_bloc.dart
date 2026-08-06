import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'employee_dashboard_event.dart';
import 'employee_dashboard_state.dart';
import '../model/attendance_model.dart';
import '../model/weekly_activity_model.dart';
import '../model/employee_model.dart';
import '../repository/employee_dashboard_repository.dart';
import 'package:my_app/services/secure_storage_service.dart';
import 'package:my_app/core/auth/auth_session_redirect.dart';
import 'package:my_app/core/error_handler/error_handler.dart';
import 'package:my_app/tasks/task_status_utils.dart';

class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  final EmployeeRepository repo;

  Timer? _pollingTimer;
  Timer? _attendancePollingTimer;
  Timer? _liveTicker;
  final SecureStorageService _storage = SecureStorageService();

  EmployeeBloc({required this.repo})
      : super(EmployeeState(loading: true)) {

    on<LoadDashboard>(_onLoadDashboard);
    on<ToggleCheckInEvent>(_onToggleCheckIn);
    on<ToggleBreakEvent>(_onToggleBreak);
    on<StartTaskPolling>(_onStartPolling);
    on<StopTaskPolling>(_onStopPolling);
    on<AttendanceTicked>(_onAttendanceTicked);
    on<PollTasksRequested>(_onPollTasksRequested);
    on<PollAttendanceRequested>(_onPollAttendanceRequested);
    on<UpdateTaskStatus>(_onUpdateTaskStatus);
    on<RegisterNotificationDevice>(_onRegisterNotificationDevice);
    on<EmployeeProfileUpdated>(_onEmployeeProfileUpdated);
    on<RefreshEmployeeProfile>(_onRefreshEmployeeProfile);
    on<RefreshEvent>(_onRefreshEvent);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onRefreshEvent(
    RefreshEvent event,
    Emitter<EmployeeState> emit,
  ) async {
    add(PollTasksRequested());
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
      final serverAttendance = await repo.fetchAttendance();
      final weeklyRaw = await repo.fetchWeeklyActivity();
      final tasks = await repo.fetchTasks();
      final sharedItems = await repo.fetchSharedItems();
      final events = await repo.fetchEvents();

      final attendance = _mergeAttendance(state.attendance, serverAttendance);
      final weeklyActivity = _weeklyWithLiveToday(weeklyRaw, attendance);

      emit(state.copyWith(
        loading: false,
        employee: employee,
        attendance: attendance,
        weeklyActivity: weeklyActivity,
        tasks: tasks,
        sharedItems: sharedItems,
        events: events,
        error: null,
      ));

      _startAttendancePolling();
      _startLiveTicker();
      // Keep task polling alive across tab switches (Home dispose must not kill it).
      if (_pollingTimer == null) {
        add(StartTaskPolling());
      }
    } catch (err) {
      emit(state.copyWith(
        loading: false,
        error: ErrorHandler.format(err),
      ));
    }
  }

  void _startLiveTicker() {
    _liveTicker?.cancel();
    _liveTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (isClosed) return;
      add(AttendanceTicked());
    });
  }

  Future<void> _onAttendanceTicked(
    AttendanceTicked event,
    Emitter<EmployeeState> emit,
  ) async {
    final a = state.attendance;
    if (a == null || !a.isCheckedIn) return;

    final AttendanceModel updated;
    if (a.onBreak) {
      updated = a.copyWith(
        totalBreak: a.totalBreak + const Duration(seconds: 1),
      );
    } else if (a.checkInTime != null) {
      // Drive the clock from check-in time so refresh/poll never drifts
      // backward (e.g. 1:05 → 1:00 from minute-truncated API values).
      var net = DateTime.now().difference(a.checkInTime!) - a.totalBreak;
      if (net.isNegative) net = Duration.zero;
      if (net < a.netWork) net = a.netWork;
      updated = a.copyWith(netWork: net);
    } else {
      updated = a.copyWith(netWork: a.netWork + const Duration(seconds: 1));
    }

    emit(state.copyWith(
      attendance: updated,
      weeklyActivity: _weeklyWithLiveToday(state.weeklyActivity, updated),
    ));
  }

  WeeklyActivityModel _weeklyWithLiveToday(
    WeeklyActivityModel? weekly,
    AttendanceModel? attendance,
  ) {
    final base = weekly ?? WeeklyActivityModel.forCalendarWeek();
    if (attendance == null) return base;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    WeeklyActivityDay? existing;
    for (final d in base.days) {
      if (_isSameDay(d.date, today)) {
        existing = d;
        break;
      }
    }

    final backendWork = existing?.netWork ?? Duration.zero;
    final backendBreak = existing?.totalBreak ?? Duration.zero;

    final Duration netWork;
    final Duration totalBreak;

    if (attendance.isCheckedIn) {
      netWork = attendance.netWork >= backendWork
          ? attendance.netWork
          : backendWork;
      totalBreak = attendance.totalBreak >= backendBreak
          ? attendance.totalBreak
          : backendBreak;
    } else {
      netWork = backendWork.inSeconds > 0 ? backendWork : attendance.netWork;
      totalBreak =
          backendBreak.inSeconds > 0 ? backendBreak : attendance.totalBreak;
    }

    return base.mergeToday(
      WeeklyActivityDay(
        date: today,
        netWork: netWork > WeeklyActivityDay.maxWorkDay
            ? WeeklyActivityDay.maxWorkDay
            : netWork,
        totalBreak: totalBreak,
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  AttendanceModel _mergeAttendance(
    AttendanceModel? current,
    AttendanceModel incoming,
  ) {
    // First load / not checked in previously.
    if (current == null) return incoming.syncedToNow();

    // New day/session: check-in timestamp changed, or we were previously logged out.
    final isNewSession = !current.isCheckedIn ||
        current.checkInTime != incoming.checkInTime;
    if (isNewSession) return incoming.syncedToNow();

    // While checked in: keep times monotonic and prevent net work from increasing on break.
    final mergedNetWork = incoming.onBreak
        ? current.netWork
        : (incoming.netWork >= current.netWork ? incoming.netWork : current.netWork);

    final mergedBreak = incoming.totalBreak >= current.totalBreak
        ? incoming.totalBreak
        : current.totalBreak;

    return incoming
        .copyWith(
          netWork: mergedNetWork,
          totalBreak: mergedBreak,
        )
        .syncedToNow();
  }

  void _startAttendancePolling() {
    _attendancePollingTimer?.cancel();
    _attendancePollingTimer = Timer.periodic(
      const Duration(seconds: 45),
          (_) async {
        if (isClosed) return;
        add(PollAttendanceRequested());
      },
    );
  }

  Future<void> _onPollAttendanceRequested(
    PollAttendanceRequested event,
    Emitter<EmployeeState> emit,
  ) async {
    final token = await _storage.readToken();
    if (token == null || token.isEmpty) return;
    try {
      final serverAttendance = await repo.fetchAttendance();
      final attendance = _mergeAttendance(state.attendance, serverAttendance);
      WeeklyActivityModel? weekly = state.weeklyActivity;
      try {
        weekly = await repo.fetchWeeklyActivity();
      } catch (_) {}
      emit(state.copyWith(
        attendance: attendance,
        weeklyActivity: _weeklyWithLiveToday(weekly, attendance),
      ));
      _startLiveTicker();
    } catch (err) {
      if (kDebugMode) {
        debugPrint("Attendance refresh error: ${ErrorHandler.format(err)}");
      }
    }
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
      AuthSessionRedirect.onAuthFailure(error: 'Session expired. Please login again.', notifyUser: true);
      return;
    }

    emit(state.copyWith(loading: true, error: null));

    try {
      final serverAttendance = await repo.toggleCheckIn();
      final attendance = _mergeAttendance(state.attendance, serverAttendance);
      final weeklyRaw = await repo.fetchWeeklyActivity();

      emit(state.copyWith(
        loading: false,
        attendance: attendance,
        weeklyActivity: _weeklyWithLiveToday(weeklyRaw, attendance),
        error: null,
      ));

      if (attendance.isCheckedIn) {
        _startLiveTicker();
      } else {
        _liveTicker?.cancel();
        _liveTicker = null;
      }
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
      AuthSessionRedirect.onAuthFailure(error: 'Session expired. Please login again.', notifyUser: true);
      return;
    }

    // Optimistic update: stop/start the correct live timer immediately.
    // This avoids "net work jumps" caused by API latency.
    final current = state.attendance;
    if (current != null && current.isCheckedIn) {
      final optimistic = current.copyWith(onBreak: !current.onBreak);
      emit(state.copyWith(
        attendance: optimistic,
        weeklyActivity: _weeklyWithLiveToday(state.weeklyActivity, optimistic),
      ));
    }

    emit(state.copyWith(loading: true, error: null));

    try {
      final serverAttendance = await repo.toggleBreak();
      final attendance = _mergeAttendance(state.attendance, serverAttendance);

      emit(state.copyWith(
        loading: false,
        attendance: attendance,
        weeklyActivity: _weeklyWithLiveToday(state.weeklyActivity, attendance),
        error: null,
      ));

      if (attendance.isCheckedIn) {
        _startLiveTicker();
      }
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
        if (isClosed) return;
        add(PollTasksRequested());
      },
    );
  }

  Future<void> _onPollTasksRequested(
    PollTasksRequested event,
    Emitter<EmployeeState> emit,
  ) async {
    final token = await _storage.readToken();
    if (token == null || token.isEmpty) return;

    try {
      final tasks = await repo.fetchTasks();
      emit(state.copyWith(tasks: tasks));
    } catch (err) {
      if (kDebugMode) {
        debugPrint("Polling error: ${ErrorHandler.format(err)}");
      }
    }
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

    final apiStatus = normalizeTaskStatusForApi(event.status);

    final optimisticTasks = state.tasks.map((task) {
      if (task.id == event.taskId) {
        return task.copyWith(status: apiStatus);
      }
      return task;
    }).toList();

    emit(state.copyWith(tasks: optimisticTasks, error: null));

    try {
      await repo.updateTaskStatus(event.taskId, apiStatus);
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

  void _onEmployeeProfileUpdated(
    EmployeeProfileUpdated event,
    Emitter<EmployeeState> emit,
  ) {
    emit(state.copyWith(employee: event.employee));
  }

  Future<void> _onRefreshEmployeeProfile(
    RefreshEmployeeProfile event,
    Emitter<EmployeeState> emit,
  ) async {
    try {
      final employee = await repo.fetchEmployeeProfile();
      emit(state.copyWith(employee: employee));
    } catch (_) {}
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
    _liveTicker?.cancel();
    _liveTicker = null;

    await repo.logout();

    emit(EmployeeState(loading: false));
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    _attendancePollingTimer?.cancel();
    _liveTicker?.cancel();
    return super.close();
  }
}