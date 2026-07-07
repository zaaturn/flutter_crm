import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/employee_dashboard/model/task_model.dart';
import 'package:my_app/tasks/task_status_utils.dart';

class AssignedTasksSection extends StatelessWidget {
  final List<TaskModel> tasks;
  final Function(int, String) onStatusChange;

  const AssignedTasksSection({
    super.key,
    required this.tasks,
    required this.onStatusChange,
  });

  static const _purple = Color(0xFF7C3AED);
  static const _purpleL = Color(0xFFF5F3FF);
  static const _textMain = Color(0xFF1E293B);
  static const _border = Color(0xFFEDE9FE);

  @override
  Widget build(BuildContext context) {
    final sortedTasks = List<TaskModel>.from(tasks)
      ..sort((a, b) => b.id.compareTo(a.id));

    final activeCount =
        sortedTasks.where((t) => t.status.toUpperCase() != 'COMPLETED').length;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'Active Tasks',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _textMain,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _purpleL,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _border),
              ),
              child: Text(
                '$activeCount REMAINING',
                style: const TextStyle(
                  fontSize: 10,
                  color: _purple,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (sortedTasks.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text('No active tasks.', style: TextStyle(color: Colors.grey)),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border, width: 1.5),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < sortedTasks.length; i++) ...[
                  _TaskExpandableBar(
                    task: sortedTasks[i],
                    onStatusChange: onStatusChange,
                  ),
                  if (i < sortedTasks.length - 1)
                    const Divider(height: 1, thickness: 1, color: _border),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _TaskExpandableBar extends StatefulWidget {
  final TaskModel task;
  final Function(int, String) onStatusChange;

  const _TaskExpandableBar({
    required this.task,
    required this.onStatusChange,
  });

  @override
  State<_TaskExpandableBar> createState() => _TaskExpandableBarState();
}

class _TaskExpandableBarState extends State<_TaskExpandableBar> {
  bool _expanded = false;

  static const _purple = Color(0xFF7C3AED);
  static const _purpleL = Color(0xFFF5F3FF);
  static const _textMain = Color(0xFF1E293B);
  static const _textMute = Color(0xFF64748B);
  static const _textHint = Color(0xFF94A3B8);
  static const _border = Color(0xFFEDE9FE);
  static const _green = Color(0xFF10B981);
  static const _red = Color(0xFFEF4444);
  static const _redL = Color(0xFFFEF2F2);
  static const _redD = Color(0xFF991B1B);
  static const _amber = Color(0xFFF59E0B);
  static const _amberL = Color(0xFFFFFBEB);
  static const _amberD = Color(0xFF92400E);
  static const _blueL = Color(0xFFEFF6FF);
  static const _blueD = Color(0xFF1E40AF);

  String _safeStatus(String raw) => taskStatusDisplayLabel(raw);

  ({String label, Color color, Color bg}) _priorityMeta(String? priority) {
    switch (priority?.toUpperCase() ?? '') {
      case 'HIGH':
        return (label: 'High', color: _redD, bg: _redL);
      case 'MEDIUM':
        return (label: 'Medium', color: _amberD, bg: _amberL);
      default:
        return (label: 'Low', color: _blueD, bg: _blueL);
    }
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return _green;
      case 'IN_PROGRESS':
        return _purple;
      default:
        return _amber;
    }
  }

  int _progress(String safeStatus) {
    if (safeStatus == 'Completed') return 100;
    if (safeStatus == 'In Progress') return 50;
    return 10;
  }

  String _dueLabel(String? dueDate) {
    if (dueDate == null || dueDate.isEmpty) return 'No date';
    final due = DateTime.tryParse(dueDate);
    if (due == null) return '—';
    return DateFormat('MMM d').format(due.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final priority = _priorityMeta(task.priority);
    final safeStatus = _safeStatus(task.status);
    final statusColor = _statusColor(task.status);
    final progress = _progress(safeStatus);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: _expanded ? _purpleL.withValues(alpha: 0.35) : Colors.white,
          child: InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _textMain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: priority.bg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      priority.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: priority.color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(Icons.calendar_today_rounded, size: 12, color: _textHint),
                  const SizedBox(width: 3),
                  Text(
                    _dueLabel(task.dueDate),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _textMute,
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 22,
                      color: _expanded ? _purple : _textHint,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 1, color: _border),
                const SizedBox(height: 12),
                const Text(
                  'DESCRIPTION',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: _textHint,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  task.description.isEmpty
                      ? 'No description provided.'
                      : task.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: _textMute,
                    height: 1.5,
                  ),
                ),
                if (task.assignedByName != null &&
                    task.assignedByName!.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'ASSIGNED BY',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: _textHint,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    task.assignedByName!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _textMain,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'STATUS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: _textHint,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: safeStatus,
                          isDense: true,
                          icon: Icon(
                            Icons.arrow_drop_down_rounded,
                            color: statusColor,
                            size: 20,
                          ),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                            DropdownMenuItem(
                              value: 'In Progress',
                              child: Text('In Progress'),
                            ),
                            DropdownMenuItem(
                              value: 'Completed',
                              child: Text('Completed'),
                            ),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            final apiStatus = v.toUpperCase().replaceAll(' ', '_');
                            widget.onStatusChange(task.id, apiStatus);
                            if (v == 'Completed') {
                              setState(() => _expanded = false);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    minHeight: 5,
                    backgroundColor: statusColor.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation(statusColor),
                  ),
                ),
              ],
            ),
          ),
          crossFadeState:
              _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}
