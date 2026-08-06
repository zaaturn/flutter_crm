import 'package:my_app/auth/auth_session.dart';
import 'package:my_app/services/secure_storage_service.dart';

/// Workspace switch for anyone who can open the admin shell (admin + superuser).
Future<bool> employeeCanSwitchWorkspace() async {
  final raw = await SecureStorageService().readAuthSessionJson();
  final session = AuthSession.fromStorageString(raw);
  if (session != null) return session.canAccessAdminDashboard;

  final role = await SecureStorageService().readRole();
  final isSuper = await SecureStorageService().readIsSuperuser();
  return isSuper || (role?.toLowerCase() == 'admin');
}
