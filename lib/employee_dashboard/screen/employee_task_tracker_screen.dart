import 'package:flutter/material.dart';
import '../model/task_model.dart';

class KanbanBoardDesktop extends StatefulWidget {
  final List<TaskModel> tasks;
  final Function(int taskId, String status) onStatusChange;

  const KanbanBoardDesktop({
    super.key,
    required this.tasks,
    required this.onStatusChange,
  });

  @override
  State<KanbanBoardDesktop> createState() => _KanbanBoardDesktopState();
}

class _KanbanBoardDesktopState extends State<KanbanBoardDesktop> {
  bool isBoardView = true;

  @override
  Widget build(BuildContext context) {
    // Logic to split tasks into columns
    final pending = widget.tasks.where((t) => t.status == 'PENDING').toList();
    final inProgress = widget.tasks.where((t) => t.status == 'IN_PROGRESS').toList();
    final completed = widget.tasks.where((t) => t.status == 'COMPLETED').toList();

    return Column(
      children: [
        // View Toggle Header
        _buildViewToggle(),
        const SizedBox(height: 16),

        // Content - Board or List View
        Expanded(
          child: isBoardView
              ? _buildBoardView(pending, inProgress, completed)
              : _buildListView(),
        ),
      ],
    );
  }

  Widget _buildViewToggle() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _ViewToggleButton(
            icon: Icons.grid_view,
            label: 'Board',
            isActive: isBoardView,
            onTap: () => setState(() => isBoardView = true),
          ),
          const SizedBox(width: 8),
          _ViewToggleButton(
            icon: Icons.list,
            label: 'List',
            isActive: !isBoardView,
            onTap: () => setState(() => isBoardView = false),
          ),
        ],
      ),
    );
  }

  Widget _buildBoardView(
      List<TaskModel> pending,
      List<TaskModel> inProgress,
      List<TaskModel> completed,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildKanbanColumn(
          "PENDING",
          "Pending",
          pending,
          const Color(0xFFF59E0B),
        ),
        const SizedBox(width: 16),
        _buildKanbanColumn(
          "IN_PROGRESS",
          "In Progress",
          inProgress,
          const Color(0xFF2563EB),
        ),
        const SizedBox(width: 16),
        _buildKanbanColumn(
          "COMPLETED",
          "Completed",
          completed,
          const Color(0xFF10B981),
        ),
      ],
    );
  }

  Widget _buildListView() {
    if (widget.tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No tasks available',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  'All Tasks',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(0),
              itemCount: widget.tasks.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final task = widget.tasks[index];
                return _buildListTile(task);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(TaskModel task) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Status Indicator
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: _getStatusColor(task.status),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),

          // Priority Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getPriorityColorForTask(task).withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              task.priority.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: _getPriorityColorForTask(task),
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Task Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    task.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Status Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(task.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getStatusColor(task.status).withOpacity(0.3),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: task.status,
                isDense: true,
                style: TextStyle(
                  color: _getStatusColor(task.status),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                items: const [
                  DropdownMenuItem(
                    value: "PENDING",
                    child: Text("Pending"),
                  ),
                  DropdownMenuItem(
                    value: "IN_PROGRESS",
                    child: Text("In Progress"),
                  ),
                  DropdownMenuItem(
                    value: "COMPLETED",
                    child: Text("Completed"),
                  ),
                ],
                onChanged: (value) {
                  if (value != null && value != task.status) {
                    widget.onStatusChange(task.id, value);
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Avatar
          CircleAvatar(
            radius: 16,
            backgroundColor: _getStatusColor(task.status).withOpacity(0.2),
            child: Text(
              task.title.isNotEmpty ? task.title[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _getStatusColor(task.status),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case "COMPLETED":
        return const Color(0xFF10B981);
      case "IN_PROGRESS":
        return const Color(0xFF2563EB);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  Color _getPriorityColorForTask(TaskModel task) {
    switch (task.priority.toUpperCase()) {
      case 'HIGH':
        return const Color(0xFFEF4444);
      case 'MEDIUM':
        return const Color(0xFFF97316);
      case 'LOW':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Widget _buildKanbanColumn(
      String statusKey,
      String title,
      List<TaskModel> columnTasks,
      Color accentColor,
      ) {
    return Expanded(
      child: DragTarget<TaskModel>(
        onWillAcceptWithDetails: (details) => details.data.status != statusKey,
        onAcceptWithDetails: (details) => widget.onStatusChange(details.data.id, statusKey),
        builder: (context, candidateData, rejectedData) {
          final bool isHighlighted = candidateData.isNotEmpty;

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isHighlighted
                    ? accentColor.withOpacity(0.5)
                    : const Color(0xFFE2E8F0),
                width: isHighlighted ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Column Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${columnTasks.length}',
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.more_horiz,
                        color: Colors.grey.shade400,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Task List
                Expanded(
                  child: columnTasks.isEmpty
                      ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 48,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No tasks',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: columnTasks.length,
                    itemBuilder: (context, index) {
                      return _DraggableTaskCard(
                        task: columnTasks[index],
                        accentColor: accentColor,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DraggableTaskCard extends StatelessWidget {
  final TaskModel task;
  final Color accentColor;

  const _DraggableTaskCard({
    required this.task,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = _buildCardContent();

    return Draggable<TaskModel>(
      data: task,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.rotate(
          angle: 0.02,
          child: Opacity(
            opacity: 0.9,
            child: _buildCardContent(isDragging: true),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: cardContent,
      ),
      child: cardContent,
    );
  }

  Widget _buildCardContent({bool isDragging = false}) {
    return Container(
      width: isDragging ? 320 : null,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDragging ? 0.15 : 0.04),
            blurRadius: isDragging ? 16 : 8,
            offset: Offset(0, isDragging ? 8 : 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Priority Badge
          _buildPriorityBadge(),
          const SizedBox(height: 12),

          // Title
          Text(
            task.title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF0F172A),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          // Description
          if (task.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              task.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Date/Time info
              _buildDateInfo(),

              // Avatar or attachment icon
              Row(
                children: [
                  if (task.attachment != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.attach_file,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  _buildAvatar(),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityBadge() {
    final priorityConfig = _getPriorityConfig();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: priorityConfig['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        priorityConfig['label'],
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: priorityConfig['color'],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Map<String, dynamic> _getPriorityConfig() {
    switch (task.priority.toUpperCase()) {
      case 'HIGH':
        return {
          'label': 'HIGH PRIORITY',
          'color': const Color(0xFFEF4444),
        };
      case 'MEDIUM':
        return {
          'label': 'MEDIUM',
          'color': const Color(0xFFF97316),
        };
      case 'LOW':
        return {
          'label': 'LOW',
          'color': const Color(0xFF10B981),
        };
      default:
        return {
          'label': task.priority.toUpperCase(),
          'color': const Color(0xFF6B7280),
        };
    }
  }

  Widget _buildDateInfo() {
    // You can customize this based on your TaskModel properties
    // For now, showing a placeholder
    return Row(
      children: [
        Icon(
          Icons.calendar_today,
          size: 12,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 4),
        Text(
          _formatDate(),
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  String _formatDate() {
    // Add your date formatting logic here
    // This is a placeholder
    return 'Today';
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 12,
      backgroundColor: accentColor.withOpacity(0.2),
      child: Text(
        task.title.isNotEmpty ? task.title[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: accentColor,
        ),
      ),
    );
  }
}

// ===================================================
// VIEW TOGGLE BUTTON
// ===================================================
class _ViewToggleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ViewToggleButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFDEEBFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? const Color(0xFF2563EB) : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}