import '../model/employee.dart';
import '../model/task.dart';
import '../model/events.dart';

class AdminDashboardState {
  final bool isLoading;
  final Employee? user;
  final String? username;
  final String? role;
  final List<Employee> liveEmployees;
  final List<Task> tasks;
  final List<DashboardEvent> events;
  final String? error;
  final String? successMessage;

  const AdminDashboardState({
    this.isLoading = false,
    this.user,
    this.username,
    this.role,
    this.liveEmployees = const [],
    this.tasks = const [],
    this.events = const [],
    this.error,
    this.successMessage,
  });

  AdminDashboardState copyWith({
    bool? isLoading,
    Employee? user,
    String? username,
    String? role,
    List<Employee>? liveEmployees,
    List<Task>? tasks,
    List<DashboardEvent>? events,
    String? error,
    String? successMessage, // ── NEW
  }) {
    return AdminDashboardState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      username: username ?? this.username,
      role: role ?? this.role,
      liveEmployees: liveEmployees ?? this.liveEmployees,
      tasks: tasks ?? this.tasks,
      events: events ?? this.events,
      error: error,
      successMessage: successMessage,
    );
  }
}