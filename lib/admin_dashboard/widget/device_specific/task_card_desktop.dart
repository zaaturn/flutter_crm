import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  State<ModrenLevelTaskRow> createState() => _ModrenLevelTaskRowState();
}

class _ModrenLevelTaskRowState extends State<ModrenLevelTaskRow> {
  bool _isHovered = false;

  // --- Daxarrow Premium Colors ---
  static const _brandPurple = Color(0xFF7C3AED); // Your main purple
  static const _purpleLight = Color(0xFFF5F3FF); // Hover background
  static const _borderPurple = Color(0xFFEDE9FE); // Subtle border
  static const _textPrimary = Color(0xFF0F172A);
  static const _textMuted = Color(0xFF64748B);

  Color get _priorityColor {
    switch (widget.task.priority.toLowerCase()) {
      case 'high': return const Color(0xFFEF4444); // Red
      case 'low': return const Color(0xFF10B981); // Green
      default: return _brandPurple; // Purple for Medium/Default
    }
  }

  Color get _statusColor {
    switch (widget.task.status.toLowerCase()) {
      case 'completed': return const Color(0xFF10B981);
      case 'in_progress': return _brandPurple;
      default: return _textMuted;
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
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: _isHovered ? _purpleLight : Colors.white,
            // Premium Bottom Border
            border: const Border(
              bottom: BorderSide(color: _borderPurple, width: 1),
            ),
          ),
          child: Row(
            children: [
              _buildPriorityIndicator(),
              const SizedBox(width: 20),

              _buildTitleSection(),

              _buildAssigneeSection(),

              _buildStatusBadge(),

              _buildDueDateSection(),

              // Action Area (Approve or Edit/Delete)
              SizedBox(
                width: 120,
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

  // --- UI COMPONENTS ---

  Widget _buildPriorityIndicator() => Container(
    width: 16, height: 16,
    decoration: BoxDecoration(
      color: _priorityColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: _priorityColor.withOpacity(0.3), width: 1),
    ),
    child: Center(
      child: Icon(Icons.bolt_rounded, size: 10, color: _priorityColor),
    ),
  );

  Widget _buildTitleSection() => Expanded(
    flex: 4,
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: _borderPurple,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            "T-${widget.task.id}",
            style: GoogleFonts.plusJakartaSans(
                color: _brandPurple,
                fontSize: 10,
                fontWeight: FontWeight.w800
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            widget.task.title,
            style: GoogleFonts.plusJakartaSans(
                color: _textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );

  Widget _buildAssigneeSection() => Expanded(
    flex: 2,
    child: Row(
      children: [
        Container(
          width: 24, height: 24,
          decoration: const BoxDecoration(color: _brandPurple, shape: BoxShape.circle),
          child: Center(
            child: Text(
                widget.task.assignedToName[0].toUpperCase(),
                style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
            child: Text(
                widget.task.assignedToName,
                style: GoogleFonts.plusJakartaSans(color: _textMuted, fontSize: 13, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis
            )
        ),
      ],
    ),
  );

  Widget _buildStatusBadge() => SizedBox(
    width: 110,
    child: Row(
      children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(color: _statusColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
            widget.task.status.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
                color: _statusColor,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5
            )
        ),
      ],
    ),
  );

  Widget _buildDueDateSection() => SizedBox(
    width: 110,
    child: Row(
      children: [
        const Icon(Icons.calendar_today_rounded, size: 14, color: _textMuted),
        const SizedBox(width: 8),
        Text(
            widget.task.dueDate,
            style: GoogleFonts.plusJakartaSans(color: _textMuted, fontSize: 12, fontWeight: FontWeight.w600)
        ),
      ],
    ),
  );

  // ── PREMIUM PURPLE APPROVE BUTTON ───────────────────────────────────
  Widget _buildApproveButton() {
    return InkWell(
      onTap: widget.onApprove,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
            color: _brandPurple, // Solid Daxarrow Purple
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(color: _brandPurple.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))
            ]
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified_rounded, size: 14, color: Colors.white),
            const SizedBox(width: 6),
            Text(
                "APPROVE",
                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)
            ),
          ],
        ),
      ),
    );
  }

  // ── HOVER ACTIONS ──────────────────────────────────────────────────
  Widget _buildHoverActions() {
    return AnimatedOpacity(
      opacity: _isHovered ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 100),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _rowIconButton(Icons.edit_note_rounded, _brandPurple, widget.onEdit),
          const SizedBox(width: 6),
          _rowIconButton(Icons.delete_outline_rounded, const Color(0xFFEF4444), widget.onDelete),
        ],
      ),
    );
  }

  Widget _rowIconButton(IconData icon, Color color, VoidCallback? action) {
    return InkWell(
      onTap: action,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}