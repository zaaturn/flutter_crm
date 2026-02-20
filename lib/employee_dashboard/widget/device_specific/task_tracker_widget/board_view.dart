import 'package:flutter/material.dart';
import 'package:my_app/employee_dashboard/model/task_model.dart';
import 'draggable_task_card.dart';

class BoardView extends StatelessWidget {
  const BoardView({
    super.key,
    required this.pending,
    required this.inProgress,
    required this.completed,
    required this.draggingTask,
    required this.hoveredColumn,
    required this.statusColor,
    required this.priorityColor,
    required this.statusLabel,
    required this.onDragStarted,
    required this.onDragEnd,
    required this.onColumnHover,
    required this.onDropped,
  });

  final List<TaskModel> pending;
  final List<TaskModel> inProgress;
  final List<TaskModel> completed;

  final TaskModel? draggingTask;
  final String? hoveredColumn;

  final Color Function(String) statusColor;
  final Color Function(String) priorityColor;
  final String Function(String) statusLabel;

  final ValueChanged<TaskModel> onDragStarted;
  final VoidCallback onDragEnd;
  final ValueChanged<String?> onColumnHover;
  final void Function(TaskModel, String) onDropped;

  static const _surface = Colors.white;
  static const _border = Color(0xFFE2E8F0);

  Color _priorityBg(String p) => switch (p.toUpperCase()) {
    'HIGH' => const Color(0xFFFEF2F2),
    'MEDIUM' => const Color(0xFFFFF7ED),
    _ => const Color(0xFFECFDF5),
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildColumn('PENDING', pending)),
        const SizedBox(width: 16),
        Expanded(child: _buildColumn('IN_PROGRESS', inProgress)),
        const SizedBox(width: 16),
        Expanded(child: _buildColumn('COMPLETED', completed)),
      ],
    );
  }

  Widget _buildColumn(String status, List<TaskModel> tasks) {
    final isHovered = hoveredColumn == status;
    final colColor = statusColor(status);

    return DragTarget<TaskModel>(
      onWillAcceptWithDetails: (details) {
        if (details.data.status == status) return false;
        onColumnHover(status);
        return true;
      },
      onLeave: (_) => onColumnHover(null),
      onAcceptWithDetails: (details) =>
          onDropped(details.data, status),
      builder: (context, candidateData, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color:
            isHovered ? colColor.withOpacity(0.04) : _surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isHovered
                  ? colColor.withOpacity(0.5)
                  : _border,
              width: isHovered ? 2 : 1,
            ),
            boxShadow: isHovered
                ? [
              BoxShadow(
                color: colColor.withOpacity(0.12),
                blurRadius: 16,
                offset: const Offset(0, 4),
              )
            ]
                : null,
          ),
          child: Column(
            children: [
              // header
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 13),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isHovered
                          ? colColor.withOpacity(0.2)
                          : _border,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: colColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        statusLabel(status),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 2),
                      decoration: BoxDecoration(
                        color: isHovered
                            ? colColor.withOpacity(0.1)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isHovered
                              ? colColor.withOpacity(0.3)
                              : _border,
                        ),
                      ),
                      child: Text(
                        '${tasks.length}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isHovered
                              ? colColor
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // drop hint
              if (isHovered && candidateData.isNotEmpty)
                AnimatedContainer(
                  duration:
                  const Duration(milliseconds: 150),
                  margin:
                  const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  padding:
                  const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: colColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colColor.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_downward_rounded,
                          size: 14, color: colColor),
                      const SizedBox(width: 6),
                      Text(
                        'Drop to move → ${statusLabel(status)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colColor,
                        ),
                      ),
                    ],
                  ),
                ),

              // cards
              Expanded(
                child: tasks.isEmpty && !isHovered
                    ? _emptyColumn(status)
                    : ListView.separated(
                  padding:
                  const EdgeInsets.all(12),
                  itemCount: tasks.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final task = tasks[i];
                    return DraggableTaskCard(
                      task: task,
                      priorityColor:
                      priorityColor(task.priority),
                      priorityBg:
                      _priorityBg(task.priority),
                      statusColor: statusColor,
                      isDragging:
                      draggingTask?.id == task.id,
                      onDragStarted: () =>
                          onDragStarted(task),
                      onDragEnd: onDragEnd,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _emptyColumn(String status) {
    final color = statusColor(status);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined,
                size: 36, color: _border),
            const SizedBox(height: 8),
            const Text(
              'No tasks',
              style:
              TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 4),
            Text(
              'Drop a card here',
              style: TextStyle(
                fontSize: 11,
                color: color.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}