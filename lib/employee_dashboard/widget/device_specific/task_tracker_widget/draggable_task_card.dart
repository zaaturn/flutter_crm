import 'package:flutter/material.dart';
import 'package:my_app/employee_dashboard/model/task_model.dart';

class DraggableTaskCard extends StatefulWidget {
  const DraggableTaskCard({
    super.key,
    required this.task,
    required this.priorityColor,
    required this.priorityBg,
    required this.statusColor,
    required this.isDragging,
    required this.onDragStarted,
    required this.onDragEnd,
  });

  final TaskModel task;
  final Color priorityColor;
  final Color priorityBg;
  final Color Function(String) statusColor;
  final bool isDragging;
  final VoidCallback onDragStarted;
  final VoidCallback onDragEnd;

  @override
  State<DraggableTaskCard> createState() =>
      _DraggableTaskCardState();
}

class _DraggableTaskCardState extends State<DraggableTaskCard> {
  bool _hovered = false;

  Widget _cardBody({bool isFeedback = false}) {
    final t = widget.task;

    return Container(
      width: isFeedback ? 260 : null,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isFeedback
              ? const Color(0xFF6366F1)
              : _hovered
              ? const Color(0xFFCBD5E1)
              : const Color(0xFFE2E8F0),
          width: isFeedback ? 2 : 1,
        ),
        boxShadow: isFeedback
            ? [
          BoxShadow(
            color:
            const Color(0xFF6366F1).withOpacity(0.2),
            blurRadius: 24,
            offset: const Offset(0, 8),
          )
        ]
            : _hovered
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ]
            : [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.drag_indicator,
                size: 16,
                color: isFeedback
                    ? const Color(0xFF6366F1)
                    : _hovered
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFFCBD5E1),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  t.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                    height: 1.4,
                  ),
                  maxLines: isFeedback ? 1 : null,
                  overflow: isFeedback
                      ? TextOverflow.ellipsis
                      : null,
                ),
              ),
            ],
          ),
          if (t.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              t.description,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: widget.priorityBg,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  t.priority.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: widget.priorityColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              CircleAvatar(
                radius: 13,
                backgroundColor: widget
                    .statusColor(t.status)
                    .withOpacity(0.12),
                child: Text(
                  t.title.isNotEmpty
                      ? t.title[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: widget.statusColor(t.status),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Draggable<TaskModel>(
      data: widget.task,
      onDragStarted: widget.onDragStarted,
      onDragEnd: (_) => widget.onDragEnd(),
      onDraggableCanceled: (_, __) => widget.onDragEnd(),

      // floating preview
      feedback: Material(
        color: Colors.transparent,
        child: Transform.rotate(
          angle: 0.018,
          child: _cardBody(isFeedback: true),
        ),
      ),

      // placeholder in original spot
      childWhenDragging:
      Opacity(opacity: 0.0, child: _cardBody()),

      child: MouseRegion(
        cursor: SystemMouseCursors.grab,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: widget.isDragging ? 0.35 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            child: _cardBody(),
          ),
        ),
      ),
    );
  }
}