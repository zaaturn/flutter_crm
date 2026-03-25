import 'package:flutter/material.dart';
import 'package:my_app/admin_dashboard/model/task.dart';

class ModrenLevelTaskRow extends StatefulWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onApprove;

  const ModrenLevelTaskRow({
    super.key,
    required this.task,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onApprove,
  });

  @override
  State<ModrenLevelTaskRow> createState() => _SaaSLevelTaskRowState();
}

class _SaaSLevelTaskRowState extends State<ModrenLevelTaskRow> {
  bool _isHovered = false;

  Color get _priorityColor {
    switch (widget.task.priority.toLowerCase()) {
      case 'high': return const Color(0xFFFF4757);
      case 'low': return const Color(0xFF10B981);
      default: return const Color(0xFFFF9800);
    }
  }

  Color get _statusColor {
    switch (widget.task.status.toLowerCase()) {
      case 'completed': return const Color(0xFF10B981);
      case 'in_progress': return const Color(0xFF3B82F6);
      default: return const Color(0xFF94A3B8);
    }
  }

  @override
  Widget build(BuildContext context) {

    final bool isCompleted = widget.task.status.toLowerCase() == 'completed';

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _isHovered ? const Color(0xFFF8FAFC) : Colors.white,
            border: const Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
          ),
          child: Row(
            children: [

              _buildPriorityIndicator(),
              const SizedBox(width: 16),


              _buildTitleSection(),


              _buildAssigneeSection(),


              _buildStatusBadge(),


              _buildDueDateSection(),


              SizedBox(
                width: 110,
                child: isCompleted
                    ? _buildApproveButton()
                    : _buildHoverActions(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- SUB-WIDGETS ---

  Widget _buildPriorityIndicator() => Container(
    width: 14, height: 14,
    decoration: BoxDecoration(
      color: _priorityColor.withOpacity(0.15),
      borderRadius: BorderRadius.circular(3),
      border: Border.all(color: _priorityColor.withOpacity(0.5), width: 1),
    ),
    child: Center(
      child: Container(width: 4, height: 4, decoration: BoxDecoration(color: _priorityColor, shape: BoxShape.circle)),
    ),
  );

  Widget _buildTitleSection() => Expanded(
    flex: 4,
    child: Row(
      children: [
        Text(
          "TASK-${widget.task.id.toString().padLeft(3, '0')}",
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w500, fontFamily: 'monospace'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            widget.task.title,
            style: const TextStyle(color: Color(0xFF1E293B), fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: -0.2),
            maxLines: 1, overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );

  Widget _buildAssigneeSection() => Expanded(
    flex: 2,
    child: Row(
      children: [
        CircleAvatar(
          radius: 10, backgroundColor: const Color(0xFFE2E8F0),
          child: Text(widget.task.assignedToName[0], style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
        ),
        const SizedBox(width: 8),
        Flexible(child: Text(widget.task.assignedToName, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13), overflow: TextOverflow.ellipsis)),
      ],
    ),
  );

  Widget _buildStatusBadge() => SizedBox(
    width: 100,
    child: Row(
      children: [
        Icon(Icons.radio_button_checked, size: 12, color: _statusColor),
        const SizedBox(width: 6),
        Text(widget.task.status.toUpperCase(), style: TextStyle(color: _statusColor, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
      ],
    ),
  );

  Widget _buildDueDateSection() => SizedBox(
    width: 120,
    child: Row(
      children: [
        const Icon(Icons.calendar_today_outlined, size: 12, color: Color(0xFF94A3B8)),
        const SizedBox(width: 6),
        Text(widget.task.dueDate, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
      ],
    ),
  );

  // ── NEW: APPROVE BUTTON ───────────────────────────────────────────
  Widget _buildApproveButton() {
    return InkWell(
      onTap: widget.onApprove,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981), // Solid Green
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, size: 14, color: Colors.white),
            SizedBox(width: 4),
            Text("APPROVE", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // ── HOVER ACTIONS (EDIT/DELETE) ──────────────────────────────────
  Widget _buildHoverActions() {
    return AnimatedOpacity(
      opacity: _isHovered ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 100),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _rowIconButton(Icons.edit_outlined, const Color(0xFF3B82F6), widget.onEdit),
          const SizedBox(width: 4),
          _rowIconButton(Icons.delete_outline, const Color(0xFFEF4444), widget.onDelete),
        ],
      ),
    );
  }

  Widget _rowIconButton(IconData icon, Color color, VoidCallback? action) {
    return InkWell(
      onTap: action,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}