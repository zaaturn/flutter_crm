import 'package:flutter/material.dart';
import 'package:my_app/employee_dashboard/model/task_model.dart';

class StatsBar extends StatelessWidget {
  const StatsBar({
    super.key,
    required this.tasks,
  });

  final List<TaskModel> tasks;

  static const _surface = Colors.white;
  static const _border = Color(0xFFE2E8F0);
  static const _textSecondary = Color(0xFF64748B);
  static const _pending = Color(0xFFF59E0B);
  static const _inprogress = Color(0xFF6366F1);
  static const _completed = Color(0xFF10B981);

  @override
  Widget build(BuildContext context) {
    // ✅ single-pass counting (senior optimization)
    int pendingCount = 0;
    int inProgressCount = 0;
    int completedCount = 0;

    for (final t in tasks) {
      switch (t.status) {
        case 'PENDING':
          pendingCount++;
          break;
        case 'IN_PROGRESS':
          inProgressCount++;
          break;
        case 'COMPLETED':
          completedCount++;
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: _surface,
        border: Border(bottom: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          _StatCard(
            label: 'Total',
            value: tasks.length,
            color: _textSecondary,
          ),
          const SizedBox(width: 12),
          _StatCard(
            label: 'Pending',
            value: pendingCount,
            color: _pending,
          ),
          const SizedBox(width: 12),
          _StatCard(
            label: 'In Progress',
            value: inProgressCount,
            color: _inprogress,
          ),
          const SizedBox(width: 12),
          _StatCard(
            label: 'Completed',
            value: completedCount,
            color: _completed,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$value',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: color,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}