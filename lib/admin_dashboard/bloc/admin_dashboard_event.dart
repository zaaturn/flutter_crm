// lib/admin_dashboard/bloc/admin_dashboard_event.dart

import 'package:my_app/tasks/models/crm_task.dart';

abstract class AdminDashboardEvent {
  const AdminDashboardEvent();
}

class AdminDashboardStarted extends AdminDashboardEvent {
  const AdminDashboardStarted();
}

class AdminDashboardRefreshed extends AdminDashboardEvent {
  const AdminDashboardRefreshed();
}

class AdminTasksRefreshed extends AdminDashboardEvent {
  const AdminTasksRefreshed();
}

class AdminTaskPatched extends AdminDashboardEvent {
  final CrmTask task;

  const AdminTaskPatched(this.task);
}

class RegisterAdminNotificationDevice extends AdminDashboardEvent {
  const RegisterAdminNotificationDevice();
}

// ── NEW APPROVE EVENT ────────────────────────────────────────────────────────

class ApproveTaskRequested extends AdminDashboardEvent {
  final int taskId;

  const ApproveTaskRequested({required this.taskId});

  List<Object> get props => [taskId];
}