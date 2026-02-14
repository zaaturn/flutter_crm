import '../model/attendance_model.dart';
import '../model/task_model.dart';
import '../model/shared_item_model.dart';
import '../model/event_model.dart';
import '../model/employee_model.dart';  // <-- ADD THIS

class EmployeeState {
  final bool loading;
  final AttendanceModel? attendance;
  final List<TaskModel> tasks;
  final List<SharedItemModel> sharedItems;
  final List<EventModel> events;
  final String? error;

  final EmployeeModel? employee;   // <-- ADD THIS LINE

  EmployeeState({
    this.loading = false,
    this.attendance,
    this.tasks = const [],
    this.sharedItems = const [],
    this.events = const [],
    this.error,
    this.employee,                 // <-- ADD THIS
  });

  EmployeeState copyWith({
    bool? loading,
    AttendanceModel? attendance,
    List<TaskModel>? tasks,
    List<SharedItemModel>? sharedItems,
    List<EventModel>? events,
    String? error,
    EmployeeModel? employee,       // <-- ADD THIS
  }) {
    return EmployeeState(
      loading: loading ?? this.loading,
      attendance: attendance ?? this.attendance,
      tasks: tasks ?? this.tasks,
      sharedItems: sharedItems ?? this.sharedItems,
      events: events ?? this.events,
      error: error ?? this.error,
      employee: employee ?? this.employee,  // <-- ADD THIS
    );
  }
}

