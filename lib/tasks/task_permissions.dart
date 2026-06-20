import 'package:my_app/auth/auth_session.dart';
import 'package:my_app/services/secure_storage_service.dart';

import 'package:my_app/tasks/models/crm_task.dart';

/// superuser OR admin OR task creator; blocked when task is approved.
Future<bool> canEditTask(CrmTask task) async {
  if (task.isApproved) return false;

  final storage = SecureStorageService();
  final session = AuthSession.fromStorageString(
    await storage.readAuthSessionJson(),
  );
  final userId = int.tryParse(await storage.readUserId() ?? '');
  if (session == null || userId == null) return false;

  if (session.isSuperuser) return true;
  if (session.isAdmin) return true;
  return task.assignedBy != null && task.assignedBy == userId;
}

/// Assignee may update status only (not full edit).
Future<bool> canUpdateTaskStatus(CrmTask task) async {
  if (task.isApproved) return false;

  final userId = int.tryParse(await SecureStorageService().readUserId() ?? '');
  if (userId == null) return false;
  return task.assignedTo != null && task.assignedTo == userId;
}
