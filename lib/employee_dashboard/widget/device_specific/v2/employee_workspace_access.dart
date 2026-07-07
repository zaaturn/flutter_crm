import 'package:my_app/auth/auth_session.dart';
import 'package:my_app/services/secure_storage_service.dart';

/// Workspace switch is only for superusers (not regular admins/employees).
Future<bool> employeeCanSwitchWorkspace() async {
  final raw = await SecureStorageService().readAuthSessionJson();
  final session = AuthSession.fromStorageString(raw);
  return session?.isSuperuser == true;
}
