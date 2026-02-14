import 'package:flutter/material.dart';
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

  // Theme Colors
  static const Color _primaryBlue = Color(0xFF137FEC);
  static const Color _textMain = Color(0xFF1E293B);
  static const Color _textMuted = Color(0xFF94A3B8);

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
            // Grid layout to match the image (2 columns on desktop)
            final crossAxisCount = constraints.maxWidth > 800 ? 2 : 1;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tasks.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.6,
              ),

              itemBuilder: (context, index) => _taskCard(tasks[index]),
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
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: _textMain,
        ),
      ),
    );
  }

  Widget _taskCard(TaskModel task) {
    final statusColor = _getStatusColor(task.status);
    final priorityInfo = _getPriorityInfo(task.priority); // Assumes priority field in model

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon Box (Top Left)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.palette_outlined, color: statusColor, size: 20),
              ),
              // Progress Circle (Top Right)
              _buildProgressCircle(task.status, statusColor),
            ],
          ),
          const SizedBox(height: 16),
          // Title
          Text(
            task.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _textMain),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Description
          Text(
            task.description,
            style: const TextStyle(fontSize: 12, color: _textMuted),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          // Bottom Status Bar
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.black.withOpacity(0.05))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Priority Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityInfo.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    priorityInfo.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: priorityInfo.color,
                    ),
                  ),
                ),
                Text(
                  _getDueDateLabel(task.status),
                  style: const TextStyle(fontSize: 11, color: _textMuted, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCircle(String status, Color color) {
    double progress = 0.0;
    String percentage = "0%";

    if (status.toUpperCase() == "COMPLETED") {
      progress = 1.0;
      percentage = "100%";
    } else if (status.toUpperCase() == "IN_PROGRESS") {
      progress = 0.5;
      percentage = "50%";
    } else {
      progress = 0.1;
      percentage = "10%";
    }

    // Changed from size: 44 to width/height
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color), // Use valueColor for fixed color
            strokeWidth: 3,
          ),
          Text(
            percentage,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B)
            ),
          ),
        ],
      ),
    );
  }
  // --- Helpers ---

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case "COMPLETED": return const Color(0xFF10B981);
      case "IN_PROGRESS": return _primaryBlue;
      default: return const Color(0xFFF59E0B);
    }
  }

  ({String label, Color color}) _getPriorityInfo(dynamic priority) {
    final p = priority?.toString().toUpperCase() ?? "LOW";
    if (p == "HIGH") return (label: "High Priority", color: const Color(0xFFF59E0B));
    if (p == "MEDIUM") return (label: "Normal", color: _primaryBlue);
    return (label: "Low", color: _textMuted);
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