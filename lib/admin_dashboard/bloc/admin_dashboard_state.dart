// lib/admin_dashboard/bloc/admin_dashboard_state.dart

import '../model/employee.dart';
import '../model/task.dart';
import '../model/events.dart';

class AdminDashboardState {
  final bool isLoading;


  final String? username;
  final String? role;

  final List<Employee> liveEmployees;
  final List<Task> tasks;
  final List<DashboardEvent> events;
  final String? error;

  const AdminDashboardState({
    this.isLoading = false,
    this.username,
    this.role,
    this.liveEmployees = const [],
    this.tasks = const [],
    this.events = const [],
    this.error,
  });

  AdminDashboardState copyWith({
    bool? isLoading,
    String? username,
    String? role,
    List<Employee>? liveEmployees,
    List<Task>? tasks,
    List<DashboardEvent>? events,
    String? error,
  }) {
    return AdminDashboardState(
      isLoading: isLoading ?? this.isLoading,
      username: username ?? this.username,
      role: role ?? this.role,
      liveEmployees: liveEmployees ?? this.liveEmployees,
      tasks: tasks ?? this.tasks,
      events: events ?? this.events,
      error: error,
    );
  }
}
