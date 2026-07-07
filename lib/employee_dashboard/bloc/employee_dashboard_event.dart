import '../model/employee_model.dart';

abstract class EmployeeEvent {}

class LoadDashboard extends EmployeeEvent {}

class ToggleCheckInEvent extends EmployeeEvent {}

class ToggleBreakEvent extends EmployeeEvent {}

class LogoutEvent extends EmployeeEvent {}

class RefreshEvent extends EmployeeEvent {}

class StartTaskPolling extends EmployeeEvent {}

class StopTaskPolling extends EmployeeEvent {}

/// Internal: 1-second UI ticker for attendance timers.
class AttendanceTicked extends EmployeeEvent {}

/// Internal: periodic server sync for tasks list.
class PollTasksRequested extends EmployeeEvent {}

/// Internal: periodic server sync for attendance.
class PollAttendanceRequested extends EmployeeEvent {}

class UpdateTaskStatus extends EmployeeEvent {
  final int taskId;
  final String status;

  UpdateTaskStatus({
    required this.taskId,
    required this.status,
  });
}

class EmployeeProfileUpdated extends EmployeeEvent {
  final EmployeeModel employee;
  EmployeeProfileUpdated(this.employee);
}

class RefreshEmployeeProfile extends EmployeeEvent {}

class RegisterNotificationDevice extends EmployeeEvent {}
