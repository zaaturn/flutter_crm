import '../model/employee.dart';
import '../model/task.dart';
import '../model/events.dart';

class AdminDashboardState {
  final bool isLoading;
  final Employee? user;
  final String? username;
  final String? role;
  /// From stored [AuthSession] at dashboard load (same source as desktop sidebar).
  final bool isSuperuser;
  final List<Employee> liveEmployees;
  final int totalEmployeeCount;
  final List<Task> tasks;
  final List<DashboardEvent> events;
  final String? error;
  final String? successMessage;

  const AdminDashboardState({
    this.isLoading = false,
    this.user,
    this.username,
    this.role,
    this.isSuperuser = false,
    this.liveEmployees = const [],
    this.totalEmployeeCount = 0,
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
    bool? isSuperuser,
    List<Employee>? liveEmployees,
    int? totalEmployeeCount,
    List<Task>? tasks,
    List<DashboardEvent>? events,
    String? error,
    String? successMessage,
  }) {
    return AdminDashboardState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      username: username ?? this.username,
      role: role ?? this.role,
      isSuperuser: isSuperuser ?? this.isSuperuser,
      liveEmployees: liveEmployees ?? this.liveEmployees,
      totalEmployeeCount: totalEmployeeCount ?? this.totalEmployeeCount,
      tasks: tasks ?? this.tasks,
      events: events ?? this.events,
      error: error,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}