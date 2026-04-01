import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/admin_dashboard/model/task.dart';

class ModernTaskCard extends StatelessWidget {
  final Task task;
  final bool isDark;
  final Function(Task)? onTap;
  final Function(Task)? onDelete;

  const ModernTaskCard({
    super.key,
    required this.task,
    required this.isDark,
    this.onTap,
    this.onDelete,
  });

  static const _brandPurple = Color(0xFF7C3AED);
  static const _textPrimary = Color(0xFF0F172A);
  static const _textMuted = Color(0xFF64748B);
  static const _borderPurple = Color(0xFFDDD6FE);

  Color _getStatusColor(String status) {
    switch (status.trim().toLowerCase()) {
      case 'completed': return const Color(0xFF10B981);
      case 'in_progress': return _brandPurple;
      default: return const Color(0xFFF59E0B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(task.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? _brandPurple.withOpacity(0.3) : _borderPurple,
          width: 1.2,
        ),
      ),
      child: InkWell(
        onTap: () => onTap?.call(task),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : _textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => onDelete?.call(task),
                    child: Icon(Icons.archive_outlined,
                        size: 20,
                        color: Colors.red.withOpacity(0.7)
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),


              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _brandPurple.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person_pin_rounded, size: 14, color: _brandPurple),
                    const SizedBox(width: 6),
                    Text(
                      "Assign to: ",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _brandPurple,
                      ),
                    ),
                    Text(
                      task.assignedToName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: _brandPurple,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),


              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatusChip(status: task.status, color: statusColor),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 12, color: _textMuted),
                      const SizedBox(width: 6),
                      Text(
                        task.dueDate,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final Color color;
  const _StatusChip({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }
}