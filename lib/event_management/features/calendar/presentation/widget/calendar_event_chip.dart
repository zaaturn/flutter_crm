import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/calendar_grid_event.dart';
import '../../shared/calendar_palette.dart';

class CalendarEventChip extends StatelessWidget {
  const CalendarEventChip({
    super.key,
    required this.event,
    this.compact = false,
    this.onTap,
  });

  final CalendarGridEvent event;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = event.blockColor;
    final textColor = event.isTaskDeadline
        ? CalendarPalette.taskDeadline
        : Colors.white;
    final bg = event.isTaskDeadline
        ? Colors.white
        : color.withValues(alpha: event.isCancelled ? 0.35 : 0.92);
    final border = event.isTaskDeadline
        ? Border.all(
            color: CalendarPalette.taskDeadline,
            width: 1.2,
          )
        : (event.priorityBorderColor != Colors.transparent
            ? Border(
                left: BorderSide(color: event.priorityBorderColor, width: 3),
              )
            : null);

    final label = event.isTaskDeadline
        ? 'Due: ${event.title}'
        : event.isAllDay
            ? event.title
            : '${DateFormat.Hm().format(event.startTime.toLocal())} ${event.title}';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: compact ? 3 : 4),
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 6 : 8,
            vertical: compact ? 3 : 4,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(6),
            border: border,
          ),
          child: Row(
            children: [
              if (event.isTaskDeadline) ...[
                Icon(
                  Icons.flag_outlined,
                  size: compact ? 11 : 12,
                  color: CalendarPalette.taskDeadline,
                ),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: compact ? 10 : 11,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    color: event.isCancelled
                        ? CalendarPalette.cancelled
                        : (event.isTaskDeadline
                            ? CalendarPalette.taskDeadline
                            : textColor),
                    decoration:
                        event.isCancelled ? TextDecoration.lineThrough : null,
                    decorationColor: CalendarPalette.cancelled,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
