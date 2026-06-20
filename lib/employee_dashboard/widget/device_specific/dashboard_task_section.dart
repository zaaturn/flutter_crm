import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/employee_dashboard/model/task_model.dart';
import 'package:my_app/tasks/task_status_utils.dart';

typedef TaskStatusCallback = void Function(int taskId, String status);

class DashboardTasksSection extends StatelessWidget {
  final List<TaskModel> tasks;
  final TaskStatusCallback onUpdateStatus;

  const DashboardTasksSection({
    super.key,
    required this.tasks,
    required this.onUpdateStatus,
  });

  static const _white = Color(0xFFFFFFFF);
  static const _purple = Color(0xFF7C3AED);
  static const _purpleL = Color(0xFFF5F3FF);
  static const _textMain = Color(0xFF0F172A);
  static const _textMute = Color(0xFF475569);
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 12),
        if (tasks.isEmpty)
          _buildEmptyState()
        else
          Container(
            decoration: BoxDecoration(
              color: _white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _border, width: 1.5),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < tasks.length; i++) ...[
                  _TaskExpandableBar(
                    task: tasks[i],
                    onUpdateStatus: onUpdateStatus,
                  ),
                  if (i < tasks.length - 1)
                    const Divider(height: 1, thickness: 1, color: _border),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Text(
          'Active tasks',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: _textMain,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            color: _purpleL,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _purple.withValues(alpha: 0.1)),
          ),
          child: Text(
            '${tasks.length}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: _purple,
            ),
          ),
        ),
        const Spacer(),
        const Text(
          'View all',
          style: TextStyle(
            fontSize: 13,
            color: _purple,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border, width: 1.5),
      ),
      child: const Column(
        children: [
          Icon(Icons.auto_awesome_rounded, size: 40, color: _purpleL),
          SizedBox(height: 12),
          Text(
            'All tasks finished',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: _textMain,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskExpandableBar extends StatefulWidget {
  final TaskModel task;
  final TaskStatusCallback onUpdateStatus;

  const _TaskExpandableBar({
    required this.task,
    required this.onUpdateStatus,
  });

  @override
  State<_TaskExpandableBar> createState() => _TaskExpandableBarState();
}

class _TaskExpandableBarState extends State<_TaskExpandableBar> {
  bool _expanded = false;

  static const _purple = Color(0xFF7C3AED);
  static const _purpleL = Color(0xFFF5F3FF);
  static const _textMain = Color(0xFF0F172A);
  static const _textMute = Color(0xFF475569);
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

  ({Color color, int pct}) _statusMeta(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return (color: _green, pct: 100);
      case 'IN_PROGRESS':
        return (color: _purple, pct: 50);
      default:
        return (color: _amber, pct: 10);
    }
  }

  String _dueLabel(String status, String? dueDate) {
    if (status.toUpperCase() == 'COMPLETED') return 'Done';
    if (dueDate == null || dueDate.isEmpty) return 'No date';
    final due = DateTime.tryParse(dueDate);
    if (due == null) return '—';
    return DateFormat('MMM d').format(due.toLocal());
  }

  Color _dueColor(String status, String? dueDate) {
    if (status.toUpperCase() == 'COMPLETED') return _green;
    if (dueDate == null || dueDate.isEmpty) return _textHint;
    final due = DateTime.tryParse(dueDate);
    if (due == null) return _textHint;

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final dueOnly = DateTime(due.year, due.month, due.day);

    if (dueOnly.isBefore(todayOnly)) return _red;
    if (dueOnly.isAtSameMomentAs(todayOnly)) return _amber;
    return _textMute;
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final priority = _priorityMeta(task.priority);
    final status = _statusMeta(task.status);
    final safeStatus = _safeStatus(task.status);
    final dueColor = _dueColor(task.status, task.dueDate);
    final dueLabel = _dueLabel(task.status, task.dueDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: _expanded ? _purpleL.withValues(alpha: 0.35) : Colors.white,
          child: InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                  const SizedBox(width: 12),
                  Icon(Icons.calendar_today_rounded, size: 13, color: dueColor),
                  const SizedBox(width: 4),
                  Text(
                    dueLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: dueColor,
                    ),
                  ),
                  const SizedBox(width: 6),
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
          secondChild: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 1, color: _border),
                const SizedBox(height: 14),
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
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'STATUS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: _textHint,
                        letterSpacing: 0.6,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: status.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: status.color.withValues(alpha: 0.25),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: safeStatus,
                          isDense: true,
                          icon: Icon(
                            Icons.arrow_drop_down_rounded,
                            color: status.color,
                            size: 20,
                          ),
                          style: TextStyle(
                            color: status.color,
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
                            widget.onUpdateStatus(task.id, apiStatus);
                            if (v == 'Completed') {
                              setState(() => _expanded = false);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'PROGRESS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: _textHint,
                        letterSpacing: 0.6,
                      ),
                    ),
                    Text(
                      '${status.pct}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: status.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: status.pct / 100,
                    minHeight: 5,
                    backgroundColor: status.color.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation(status.color),
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
