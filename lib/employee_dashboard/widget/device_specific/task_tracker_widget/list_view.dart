import 'package:flutter/material.dart';
import 'package:my_app/employee_dashboard/model/task_model.dart';

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

  static const _surface = Colors.white;
  static const _border = Color(0xFFE2E8F0);
  static const _bg = Color(0xFFF8FAFC);

  Color _statusBg(String s) => switch (s.toUpperCase()) {
    'IN_PROGRESS' => const Color(0xFFEEF2FF),
    'COMPLETED' => const Color(0xFFECFDF5),
    _ => const Color(0xFFFFFBEB),
  };

  Color _priorityBg(String p) => switch (p.toUpperCase()) {
    'HIGH' => const Color(0xFFFEF2F2),
    'MEDIUM' => const Color(0xFFFFF7ED),
    _ => const Color(0xFFECFDF5),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
            decoration: const BoxDecoration(
              color: _bg,
              border: Border(bottom: BorderSide(color: _border)),
              borderRadius:
              BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: HeaderCell('Task')),
                Expanded(flex: 1, child: HeaderCell('Priority')),
                Expanded(flex: 2, child: HeaderCell('Status')),
                Expanded(flex: 1, child: HeaderCell('Assignee')),
              ],
            ),
          ),
          Expanded(
            child: tasks.isEmpty
                ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_outlined,
                      size: 56, color: _border),
                  SizedBox(height: 12),
                  Text(
                    'No tasks available',
                    style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF94A3B8)),
                  ),
                ],
              ),
            )
                : ListView.separated(
              itemCount: tasks.length,
              separatorBuilder: (_, __) =>
              const Divider(height: 1, color: _border),
              itemBuilder: (_, i) => _ListRow(
                task: tasks[i],
                statusColor: statusColor,
                statusBg: _statusBg,
                statusLabel: statusLabel,
                priorityColor: priorityColor,
                priorityBg: _priorityBg,
                onStatusChange: onStatusChange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListRow extends StatefulWidget {
  const _ListRow({
    required this.task,
    required this.statusColor,
    required this.statusBg,
    required this.statusLabel,
    required this.priorityColor,
    required this.priorityBg,
    required this.onStatusChange,
  });

  final TaskModel task;
  final Color Function(String) statusColor;
  final Color Function(String) statusBg;
  final String Function(String) statusLabel;
  final Color Function(String) priorityColor;
  final Color Function(String) priorityBg;
  final void Function(int, String) onStatusChange;

  @override
  State<_ListRow> createState() => _ListRowState();
}

class _ListRowState extends State<_ListRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.task;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        color: _hovered ? const Color(0xFFF8FAFC) : Colors.white,
        padding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Container(
                    width: 3,
                    height: 38,
                    decoration: BoxDecoration(
                      color: widget.statusColor(t.status),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (t.description.isNotEmpty)
                          Text(
                            t.description,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: widget.priorityBg(t.priority),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  t.priority.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: widget.priorityColor(t.priority),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: widget.statusBg(t.status),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.statusColor(t.status)
                        .withOpacity(0.25),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: t.status,
                    isDense: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      size: 14,
                      color: widget.statusColor(t.status),
                    ),
                    style: TextStyle(
                      color: widget.statusColor(t.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    items: const [
                      DropdownMenuItem(
                          value: 'PENDING',
                          child: Text('Pending')),
                      DropdownMenuItem(
                          value: 'IN_PROGRESS',
                          child: Text('In Progress')),
                      DropdownMenuItem(
                          value: 'COMPLETED',
                          child: Text('Completed')),
                    ],
                    onChanged: (v) {
                      if (v != null && v != t.status) {
                        widget.onStatusChange(t.id, v);
                      }
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: CircleAvatar(
                radius: 14,
                backgroundColor:
                widget.statusColor(t.status).withOpacity(0.1),
                child: Text(
                  t.title.isNotEmpty
                      ? t.title[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: widget.statusColor(t.status),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}