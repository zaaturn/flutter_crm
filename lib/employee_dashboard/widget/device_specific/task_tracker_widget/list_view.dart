import 'package:flutter/material.dart';
import 'package:my_app/employee_dashboard/model/task_model.dart';
import 'package:my_app/tasks/task_status_utils.dart';
import 'shared_widgets.dart';

class TaskListView extends StatelessWidget {
  const TaskListView({
    super.key,
    required this.tasks,
    required this.onStatusChange,
    required this.statusColor,
    required this.priorityColor,
    required this.statusLabel,
  });

  final List<TaskModel> tasks;
  final void Function(int, String) onStatusChange;
  final Color Function(String) statusColor;
  final Color Function(String) priorityColor;
  final String Function(String) statusLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Row(
              children: [
                Expanded(flex: 6, child: HeaderCell('TASK')),
                Expanded(flex: 2, child: HeaderCell('PRIORITY')),
                Expanded(flex: 2, child: HeaderCell('STATUS')),
                Expanded(flex: 1, child: HeaderCell('ASSIGNEE')),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: tasks.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFE2E8F0)),
              itemBuilder: (_, i) => _ListRow(
                task: tasks[i],
                statusColor: statusColor,
                priorityColor: priorityColor,
                onStatusChange: onStatusChange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListRow extends StatelessWidget {
  const _ListRow({
    required this.task,
    required this.statusColor,
    required this.priorityColor,
    required this.onStatusChange,
  });

  final TaskModel task;
  final Color Function(String) statusColor;
  final Color Function(String) priorityColor;
  final void Function(int, String) onStatusChange;

  @override
  Widget build(BuildContext context) {
    final safeStatus = taskStatusDisplayLabel(task.status);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: statusColor(task.status),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          height: 1.5,
                        ),
                        softWrap: true,
                        maxLines: null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.only(top: 4),
              child: UnconstrainedBox(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor(task.priority).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    task.priority,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: priorityColor(task.priority),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor(task.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor(task.status).withOpacity(0.2)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: safeStatus,
                  isDense: true,
                  style: TextStyle(
                    color: statusColor(task.status),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'In Progress', child: Text('In Progress')),
                    DropdownMenuItem(value: 'Completed', child: Text('Completed')),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      onStatusChange(task.id, normalizeTaskStatusForApi(v));
                    }
                  },
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: CircleAvatar(
                radius: 14,
                backgroundColor: statusColor(task.status).withOpacity(0.1),
                child: Text(
                  task.title.isNotEmpty ? task.title[0] : '?',
                  style: TextStyle(fontSize: 12, color: statusColor(task.status)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
