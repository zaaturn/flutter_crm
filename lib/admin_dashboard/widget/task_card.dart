import 'package:flutter/material.dart';

import '../model/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;

  const TaskCard({
    super.key,
    required this.task,
  });

  Color _statusColor() {
    switch (task.status) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  String _statusText() {
    switch (task.status) {
      case 'completed':
        return 'Completed';
      case 'in_progress':
        return 'In Progress';
      default:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------- TOP ROW ----------------
          Row(
            children: [
              _StatusChip(
                text: _statusText(),
                color: _statusColor(),
              ),
              const Spacer(),
              const Icon(Icons.assignment_outlined,
                  size: 20, color: Colors.black38),
            ],
          ),

          const SizedBox(height: 12),

          // ---------------- TITLE ----------------
          Text(
            task.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 6),

          // ---------------- DESCRIPTION ----------------
          if (task.description.isNotEmpty)
            Text(
              task.description,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

          const Divider(height: 24),

          // ---------------- FOOTER ----------------
          Row(
            children: [
              const Icon(Icons.person_outline,
                  size: 16, color: Colors.black45),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  task.assignedToName ?? 'Unassigned',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(width: 12),

              const Icon(Icons.calendar_today,
                  size: 14, color: Colors.black45),
              const SizedBox(width: 4),
              Text(
                task.dueDate ?? '-',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black45,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/* ============================================================
 * STATUS CHIP
 * ============================================================ */
class _StatusChip extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusChip({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
