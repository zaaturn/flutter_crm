import 'package:flutter/material.dart';
import 'package:my_app/employee_dashboard/model/task_model.dart'; // Keep your existing import

typedef TaskStatusCallback = void Function(int taskId, String status);

class DashboardTasksSection extends StatelessWidget {
  final List<TaskModel> tasks;
  final TaskStatusCallback onUpdateStatus;

  const DashboardTasksSection({
    super.key,
    required this.tasks,
    required this.onUpdateStatus,
  });

  static const Color _textMain = Color(0xFF1E293B);
  static const Color _textMuted = Color(0xFF64748B);
  static const Color _borderColor = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(),
        const SizedBox(height: 16),
        tasks.isEmpty
            ? _emptyState()
            : LayoutBuilder(
          builder: (context, constraints) {

            final double spacing = 16.0;
            final double cardWidth = constraints.maxWidth > 900
                ? (constraints.maxWidth - spacing) / 2
                : constraints.maxWidth;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: tasks.map((task) => SizedBox(
                width: cardWidth,
                child: _taskCard(task),
              )).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        "Active Tasks",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: _textMain,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _taskCard(TaskModel task) {
    final statusColor = _getStatusColor(task.status);
    final priorityInfo = _getPriorityInfo(task.priority);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Allows card to shrink/wrap content
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon Header
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.palette_outlined, color: statusColor, size: 20),
                ),
                // Modern Progress Circle
                _buildProgressCircle(task.status, statusColor),
              ],
            ),
            const SizedBox(height: 16),
            // Title
            Text(
              task.title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: _textMain,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            // Description - Removed maxLines to show full text
            Text(
              task.description,
              style: const TextStyle(
                fontSize: 13,
                color: _textMuted,
                height: 1.5, // Increased line height for SaaS readability
              ),
            ),
            const SizedBox(height: 20),
            // Bottom Divider & Meta Info
            Container(
              padding: const EdgeInsets.only(top: 14),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: _borderColor, width: 0.8)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Priority Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: priorityInfo.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      priorityInfo.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: priorityInfo.color,
                      ),
                    ),
                  ),
                  // Time Label
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: _textMuted),
                      const SizedBox(width: 4),
                      Text(
                        _getDueDateLabel(task.status),
                        style: const TextStyle(
                          fontSize: 12,
                          color: _textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCircle(String status, Color color) {
    double progress = 0.1;
    String percentage = "10%";

    if (status.toUpperCase() == "COMPLETED") {
      progress = 1.0;
      percentage = "100%";
    } else if (status.toUpperCase() == "IN_PROGRESS") {
      progress = 0.5;
      percentage = "50%";
    }

    return SizedBox(
      width: 42,
      height: 42,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeWidth: 3.5,
            strokeCap: StrokeCap.round, // Modern rounded edges on progress
          ),
          Text(
            percentage,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: _textMain,
            ),
          ),
        ],
      ),
    );
  }

  // --- Logic Helpers (Unchanged) ---

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case "COMPLETED": return const Color(0xFF10B981);
      case "IN_PROGRESS": return const Color(0xFF3B82F6);
      default: return const Color(0xFFF59E0B);
    }
  }

  ({String label, Color color}) _getPriorityInfo(dynamic priority) {
    final p = priority?.toString().toUpperCase() ?? "LOW";
    if (p == "HIGH") return (label: "High Priority", color: const Color(0xFFEF4444));
    if (p == "MEDIUM") return (label: "Medium", color: const Color(0xFFF59E0B));
    return (label: "Low", color: const Color(0xFF64748B));
  }

  String _getDueDateLabel(String status) {
    return status.toUpperCase() == "COMPLETED" ? "Finished" : "Due in 2h";
  }

  Widget _emptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Text("No active tasks.", style: TextStyle(color: _textMuted)),
      ),
    );
  }
}