abstract class EmployeeEvent {}

class LoadDashboard extends EmployeeEvent {}

class ToggleCheckInEvent extends EmployeeEvent {}

class ToggleBreakEvent extends EmployeeEvent {}

class LogoutEvent extends EmployeeEvent {}

class RefreshEvent extends EmployeeEvent {}

class StartTaskPolling extends EmployeeEvent {}

class StopTaskPolling extends EmployeeEvent {}

class UpdateTaskStatus extends EmployeeEvent {
  final int taskId;
  final String status;

  UpdateTaskStatus({
    required this.taskId,
    required this.status,
  });
}


class RegisterNotificationDevice extends EmployeeEvent {}
