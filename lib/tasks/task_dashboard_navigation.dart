import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_app/admin_dashboard/bloc/admin_dashboard_bloc.dart';
import 'package:my_app/admin_dashboard/bloc/admin_dashboard_event.dart';
import 'package:my_app/tasks/models/crm_task.dart';
import 'package:my_app/tasks/presentation/task_edit_screen.dart';

import 'package:my_app/tasks/presentation/task_detail_screen.dart';

/// Keeps workspace / tracker task lists in sync after edits.
void applyTaskEditToDashboard(BuildContext context, CrmTask updated) {
  try {
    final bloc = context.read<AdminDashboardBloc>();
    bloc.add(AdminTaskPatched(updated));
    bloc.add(const AdminTasksRefreshed());
  } catch (_) {}
}

Future<void> openTaskEditForDashboard(
  BuildContext context,
  int taskId,
) async {
  final updated = await Navigator.of(context).push<CrmTask>(
    MaterialPageRoute(
      builder: (_) => TaskEditScreen(taskId: taskId),
    ),
  );
  if (!context.mounted || updated == null) return;
  applyTaskEditToDashboard(context, updated);
}

Future<void> openTaskDetailForDashboard(
  BuildContext context, {
  required int taskId,
  required void Function(CrmTask updated) onUpdated,
}) async {
  await Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => TaskDetailScreen(
        taskId: taskId,
        onUpdated: onUpdated,
      ),
    ),
  );
}
