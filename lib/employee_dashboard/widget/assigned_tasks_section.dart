import 'package:flutter/material.dart';
import '../model/task_model.dart';

class AssignedTasksSection extends StatelessWidget {
  final List<TaskModel> tasks;
  final Function(int taskId, String status) onStatusChange;

  const AssignedTasksSection({
    super.key,
    required this.tasks,
    required this.onStatusChange,
  });

  static const Color bgLight = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color primaryIndigo = Color(0xFF4F46E5);
  static const Color textDark = Color(0xFF1E293B);
  static const Color successGreen = Color(0xFF10B981);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(),
        const SizedBox(height: 12),
        if (tasks.isEmpty)
          _buildEmptyState()
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              return _TaskCard(
                task: tasks[index],
                onStatusChange: onStatusChange,
              );
            },
          ),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "ASSIGNED TASKS",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: textSecondary,
            letterSpacing: 1.5,
          ),
        ),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(50, 30),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            "See All",
            style: TextStyle(
              color: primaryIndigo,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textSecondary.withOpacity(0.1)),
      ),
      child: const Text(
        "No tasks assigned today.",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final TaskModel task;
  final Function(int taskId, String status) onStatusChange;

  const _TaskCard({required this.task, required this.onStatusChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AssignedTasksSection.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildStatusDropdown(),
                  ],
                ),
              ),
            ],
          ),
          if (task.description.isNotEmpty) _buildDescription(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(
              height: 1,
              color: AssignedTasksSection.bgLight,
            ),
          ),
          Row(
            children: [
              Expanded(child: _buildAttachmentTag()),
              const SizedBox(width: 8),
              _buildPriorityChip(task.priority),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AssignedTasksSection.bgLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.assignment_outlined,
        size: 18,
        color: AssignedTasksSection.primaryIndigo,
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AssignedTasksSection.bgLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: task.status,
          isDense: true,
          itemHeight: 32,
          icon: const Icon(
            Icons.expand_more_rounded,
            size: 14,
            color: AssignedTasksSection.textSecondary,
          ),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AssignedTasksSection.textDark,
          ),
          items: const [
            DropdownMenuItem(value: "PENDING", child: Text("Pending")),
            DropdownMenuItem(value: "IN_PROGRESS", child: Text("In Progress")),
            DropdownMenuItem(value: "COMPLETED", child: Text("Completed")),
          ],
          onChanged: (value) =>
          value != null ? onStatusChange(task.id, value) : null,
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(
        task.description,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AssignedTasksSection.textSecondary,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildAttachmentTag() {
    if (task.attachment == null || task.attachment!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Icon(
          Icons.attach_file_rounded,
          size: 12,
          color: AssignedTasksSection.primaryIndigo,
        ),
        SizedBox(width: 4),
        Flexible(
          child: Text(
            "Files",
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AssignedTasksSection.primaryIndigo,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityChip(String priority) {
    Color color;
    switch (priority) {
      case "HIGH":
        color = const Color(0xFFE11D48);
        break;
      case "MEDIUM":
        color = const Color(0xFFF59E0B);
        break;
      case "LOW":
        color = AssignedTasksSection.successGreen;
        break;
      default:
        color = AssignedTasksSection.textSecondary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        priority,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 9,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
