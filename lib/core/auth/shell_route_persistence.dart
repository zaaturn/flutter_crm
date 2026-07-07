import 'package:my_app/auth/auth_session.dart';
import 'package:my_app/services/secure_storage_service.dart';

/// Persists which shell the user last used so browser refresh restores it.
abstract final class ShellRoutePersistence {
  static const employee = '/employeeDashboard';
  static const admin = '/adminDashboard';

  static Future<void> markEmployeeShell() async {
    final storage = SecureStorageService();
    await storage.saveLastShellRoute(employee);
    await storage.saveActiveDashboard(ActiveDashboard.employee.storageValue);
  }

  static Future<void> markAdminShell() async {
    final storage = SecureStorageService();
    await storage.saveLastShellRoute(admin);
    await storage.saveActiveDashboard(ActiveDashboard.admin.storageValue);
  }

  static Future<String?> readLastShellRoute() =>
      SecureStorageService().readLastShellRoute();
}
