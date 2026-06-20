import 'package:my_app/admin_dashboard/model/task.dart';
import 'package:my_app/tasks/models/crm_task.dart';

extension CrmTaskDashboardMapper on CrmTask {
  Task toDashboardTask() {
    return Task(
      id: id,
      title: title,
      description: description,
      priority: priority,
      dueDate: dueDate ?? '',
      assignedToName: assignedToName ?? 'Unassigned',
      status: status.trim().toLowerCase(),
      isApproved: isApproved,
    );
  }
}
