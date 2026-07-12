import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  static const _terracottaDark = Color(0xFFA84A2E);
  static const _creamMuted = Color(0xFFF2EDE4);
  static const _textMain = Color(0xFF2C241E);
  static const _border = Color(0xFFE8DFD4);

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
            Text(
              'Active Tasks',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _textMain,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _creamMuted,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _border),
              ),
              child: Text(
                '$activeCount REMAINING',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  color: _terracottaDark,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (sortedTasks.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No active tasks.',
              style: GoogleFonts.plusJakartaSans(color: Colors.grey),
            ),
          )
        else
          Column(
            children: [
              for (var i = 0; i < sortedTasks.length; i++) ...[
                _TaskExpandableBar(
                  task: sortedTasks[i],
                  onStatusChange: onStatusChange,
                ),
                if (i < sortedTasks.length - 1) const SizedBox(height: 10),
              ],
            ],
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

  static const _terracotta = Color(0xFFC05C39);
  static const _terracottaDark = Color(0xFFA84A2E);
  static const _textMain = Color(0xFF2C241E);
  static const _green = Color(0xFF10B981);
  static const _amber = Color(0xFFF59E0B);

  String _safeStatus(String raw) => taskStatusDisplayLabel(raw);

  ({String label, Color color, Color bg}) _priorityMeta(String? priority) {
    switch (priority?.toUpperCase() ?? '') {
      case 'HIGH':
        return (
          label: 'High',
          color: const Color(0xFFB42318),
          bg: const Color(0xFFFFE4E1),
        );
      case 'MEDIUM':
        return (
          label: 'Medium',
          color: const Color(0xFF92400E),
          bg: const Color(0xFFFFF1D6),
        );
      default:
        return (
          label: 'Low',
          color: const Color(0xFF1D4ED8),
          bg: const Color(0xFFE8F0FF),
        );
    }
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return _green;
      case 'IN_PROGRESS':
        return Colors.white;
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

    return Container(
      decoration: BoxDecoration(
        color: _terracotta,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _terracottaDark.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: priority.bg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        priority.label,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: priority.color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 12,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      _dueLabel(task.dueDate),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 22,
                        color: Colors.white.withValues(alpha: 0.9),
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
                  Divider(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'DESCRIPTION',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white.withValues(alpha: 0.7),
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    task.description.isEmpty
                        ? 'No description provided.'
                        : task.description,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.92),
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (task.assignedByName != null &&
                      task.assignedByName!.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'ASSIGNED BY',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.assignedByName!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'STATUS',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: safeStatus,
                            isDense: true,
                            dropdownColor: Colors.white,
                            icon: Icon(
                              Icons.arrow_drop_down_rounded,
                              color: statusColor == Colors.white
                                  ? Colors.white
                                  : statusColor,
                              size: 20,
                            ),
                            style: GoogleFonts.plusJakartaSans(
                              color: _textMain,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                            selectedItemBuilder: (context) => [
                              for (final label in const [
                                'Pending',
                                'In Progress',
                                'Completed',
                              ])
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    label,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                            ],
                            items: const [
                              DropdownMenuItem(
                                  value: 'Pending', child: Text('Pending')),
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
                              final apiStatus =
                                  v.toUpperCase().replaceAll(' ', '_');
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
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
