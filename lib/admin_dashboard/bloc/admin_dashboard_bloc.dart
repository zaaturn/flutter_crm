import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';

import 'admin_dashboard_event.dart';
import 'admin_dashboard_state.dart';
import 'package:my_app/admin_dashboard/repository/admin_repository.dart';
import 'package:my_app/auth/auth_session.dart';
import 'package:my_app/core/auth/auth_session_redirect.dart';
import 'package:my_app/services/secure_storage_service.dart';

import '../model/employee.dart';
import '../model/task.dart';
import '../model/events.dart';
import 'package:my_app/tasks/task_dashboard_mapper.dart';

class AdminDashboardBloc extends Bloc<AdminDashboardEvent, AdminDashboardState> {
  final AdminRepository repository;

  AdminDashboardBloc({required this.repository})
      : super(const AdminDashboardState()) {
    on<AdminDashboardStarted>(_onStarted);
    on<AdminDashboardRefreshed>(_onRefreshed);
    on<AdminTasksRefreshed>(_onTasksRefreshed);
    on<AdminTaskPatched>(_onTaskPatched);
    on<RegisterAdminNotificationDevice>(_onRegisterNotificationDevice);

    // ── NEW HANDLER ──────────────────────────────────────────────────────────
    on<ApproveTaskRequested>(_onApproveTaskRequested);
  }

  /* ---------------------------------------------------------
   * INITIAL LOAD
   * --------------------------------------------------------- */
  Future<void> _onStarted(
      AdminDashboardStarted event,
      Emitter<AdminDashboardState> emit,
      ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final profile = await repository.fetchProfile();
      final attendance = await repository.fetchLiveAttendance();
      final List<Task> tasks = await repository.fetchTasks();
      final List<DashboardEvent> events = await repository.fetchEvents();

      final raw = await SecureStorageService().readAuthSessionJson();
      final session = AuthSession.fromStorageString(raw);

      emit(state.copyWith(
        isLoading: false,
        username: profile.username,
        role: profile.role,
        isSuperuser: session?.isSuperuser ?? false,
        liveEmployees: attendance.todayLoggedIn,
        totalEmployeeCount: attendance.totalEmployees,
        tasks: tasks,
        events: events,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: AuthSessionRedirect.resolveBlocError(e),
      ));
    }
  }

  /* ---------------------------------------------------------
   *  APPROVE & ARCHIVE TASK
   * --------------------------------------------------------- */
  Future<void> _onApproveTaskRequested(
      ApproveTaskRequested event,
      Emitter<AdminDashboardState> emit,
      ) async {
    try {
      await repository.approveTask(event.taskId);

      final updatedTasks = state.tasks
          .where((t) => t.id != event.taskId)
          .toList();

      emit(state.copyWith(tasks: updatedTasks));

      debugPrint("✅ Task ${event.taskId} approved and archived");
    } catch (e) {
      emit(state.copyWith(error: AuthSessionRedirect.resolveBlocError(e)));
    }
  }

  /* ---------------------------------------------------------
   * REFRESH LIVE EMPLOYEES
   * --------------------------------------------------------- */
  Future<void> _onRefreshed(
      AdminDashboardRefreshed event,
      Emitter<AdminDashboardState> emit,
      ) async {
    try {
      final attendance = await repository.fetchLiveAttendance();
      emit(state.copyWith(
        liveEmployees: attendance.todayLoggedIn,
        totalEmployeeCount: attendance.totalEmployees,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(error: AuthSessionRedirect.resolveBlocError(e)));
    }
  }

  /* ---------------------------------------------------------
   * REFRESH TASKS
   * --------------------------------------------------------- */
  Future<void> _onTasksRefreshed(
      AdminTasksRefreshed event,
      Emitter<AdminDashboardState> emit,
      ) async {
    try {
      final List<Task> tasks = await repository.fetchTasks();
      emit(state.copyWith(tasks: tasks, error: null));
    } catch (e) {
      emit(state.copyWith(error: AuthSessionRedirect.resolveBlocError(e)));
    }
  }

  Future<void> _onTaskPatched(
      AdminTaskPatched event,
      Emitter<AdminDashboardState> emit,
      ) async {
    final patched = event.task.toDashboardTask();
    final updated = state.tasks
        .map((t) => t.id == patched.id ? patched : t)
        .toList();
    emit(state.copyWith(tasks: updated, error: null));
  }

  /* ---------------------------------------------------------
   *  REGISTER ADMIN NOTIFICATION DEVICE
   * --------------------------------------------------------- */
  Future<void> _onRegisterNotificationDevice(
      RegisterAdminNotificationDevice event,
      Emitter<AdminDashboardState> emit,
      ) async {
    try {
      await repository.registerNotificationDevice();
      debugPrint("✅ Admin notification device registered");
    } catch (e) {
      debugPrint("❌ Admin notification registration failed: $e");
    }
  }
}