// lib/admin_dashboard/bloc/admin_dashboard_event.dart

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


class RegisterAdminNotificationDevice extends AdminDashboardEvent {
  const RegisterAdminNotificationDevice();
}
