import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Ensure intl is in your pubspec.yaml
import 'package:my_app/employee_dashboard/model/task_model.dart';

typedef TaskStatusCallback = void Function(int taskId, String status);

class DashboardTasksSection extends StatelessWidget {
  final List<TaskModel> tasks;
  final TaskStatusCallback onUpdateStatus;

  const DashboardTasksSection({
    super.key,
    required this.tasks,
    required this.onUpdateStatus,
  });

  // --- Professional SaaS Palette ---
  static const _white    = Color(0xFFFFFFFF);
  static const _purple   = Color(0xFF7C3AED);
  static const _purpleL  = Color(0xFFF5F3FF);

  // DARKER HEADINGS (Deep Navy/Slate)
  static const _textMain = Color(0xFF0F172A);
  static const _textMute = Color(0xFF475569);
  static const _textHint = Color(0xFF94A3B8);

  static const _border   = Color(0xFFEDE9FE);

  static const _green    = Color(0xFF10B981);
  static const _greenL   = Color(0xFFECFDF5);
  static const _red      = Color(0xFFEF4444);
  static const _redL     = Color(0xFFFEF2F2);
  static const _redD     = Color(0xFF991B1B);
  static const _amber    = Color(0xFFF59E0B);
  static const _amberL   = Color(0xFFFFFBEB);
  static const _amberD   = Color(0xFF92400E);
  static const _blueL    = Color(0xFFEFF6FF);
  static const _blueD    = Color(0xFF1E40AF);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        tasks.isEmpty
            ? _buildEmptyState()
            : LayoutBuilder(
          builder: (context, c) {
            final cols = c.maxWidth > 700 ? 2 : 1;
            final w = (c.maxWidth - (cols - 1) * 12) / cols;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: tasks
                  .map((t) => SizedBox(width: w, child: _buildCard(t)))
                  .toList(),
            );
          },
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
            fontWeight: FontWeight.w900, // Extra bold
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
            border: Border.all(color: _purple.withOpacity(0.1)),
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
        Text(
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

  Widget _buildCard(TaskModel task) {
    final s = _statusMeta(task.status);
    final p = _priorityMeta(task.priority);

    return Container(
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _purple.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: s.iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(s.icon, size: 20, color: s.color),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${s.pct}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: s.color,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      width: 60,
                      height: 5,
                      child: LinearProgressIndicator(
                        value: s.pct / 100,
                        backgroundColor: s.color.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation(s.color),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            task.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800, // Very dark/bold heading
              color: _textMain,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            task.description,
            style: const TextStyle(
              fontSize: 13,
              color: _textMute,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.only(top: 16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: _border, width: 1.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: p.bg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    p.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: p.color,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: _dueColor(task.status, task.dueDate),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getDueDateLabel(task.status, task.dueDate), // FORMATTED DATE
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _dueColor(task.status, task.dueDate),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- FIXED DATE LOGIC ---
  String _getDueDateLabel(String status, String? dueDate) {
    if (status.toUpperCase() == 'COMPLETED') return 'Finished';
    if (dueDate == null || dueDate.isEmpty)  return 'No date';

    final due = DateTime.tryParse(dueDate);
    if (due == null) return 'Invalid';

    // This returns the actual date like "Mar 31" or "Oct 24"
    return DateFormat('MMM d').format(due.toLocal());
  }

  Color _dueColor(String status, String? dueDate) {
    if (status.toUpperCase() == 'COMPLETED') return _green;
    if (dueDate == null || dueDate.isEmpty)  return _textHint;
    final due = DateTime.tryParse(dueDate);
    if (due == null) return _textHint;

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final dueOnly = DateTime(due.year, due.month, due.day);

    // Keep color red if overdue, but the text will show the date
    if (dueOnly.isBefore(todayOnly)) return _red;
    if (dueOnly.isAtSameMomentAs(todayOnly)) return _amber;
    return _textMute;
  }

  // --- Status & Priority (Purple Theme) ---

  ({Color color, Color iconBg, IconData icon, int pct}) _statusMeta(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return (color: _green,  iconBg: _greenL, icon: Icons.check_circle_rounded, pct: 100);
      case 'IN_PROGRESS':
        return (color: _purple, iconBg: _purpleL, icon: Icons.auto_mode_rounded, pct: 50);
      default:
        return (color: _amber,  iconBg: _amberL,  icon: Icons.timer_outlined, pct: 10);
    }
  }

  ({String label, Color color, Color bg}) _priorityMeta(dynamic priority) {
    switch (priority?.toString().toUpperCase() ?? '') {
      case 'HIGH':
        return (label: 'High priority', color: _redD,   bg: _redL);
      case 'MEDIUM':
        return (label: 'Medium',        color: _amberD, bg: _amberL);
      default:
        return (label: 'Low',           color: _blueD,  bg: _blueL);
    }
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border, width: 2),
      ),
      child: const Column(
        children: [
          Icon(Icons.auto_awesome_rounded, size: 48, color: _purpleL),
          SizedBox(height: 16),
          Text(
            'All tasks finished',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _textMain),
          ),
        ],
      ),
    );
  }
}