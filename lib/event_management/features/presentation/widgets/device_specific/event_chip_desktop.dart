import 'package:flutter/material.dart';
import 'package:my_app/event_management/core/constants/app_colors.dart';
import 'package:my_app/event_management/features/domain/entities/event_entity.dart';

/// ─────────────────────────────────────────────────────────
/// BIG CHIP → Used in hourly / agenda view
/// ─────────────────────────────────────────────────────────
class EventChipDesktop extends StatelessWidget {
  final EventEntity event;
  final VoidCallback onTap;
  final double availableHeight; // ✅ new

  const EventChipDesktop({
    super.key,
    required this.event,
    required this.onTap,
    required this.availableHeight,
  });

  @override
  Widget build(BuildContext context) {
    final tc = EventTypeColor.of(event.eventType);

    // Decide what to show based on height
    final showTime = availableHeight > 40;
    final showJoin = availableHeight > 70;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 8,
          vertical: availableHeight < 32 ? 2 : 6,
        ),
        decoration: BoxDecoration(
          color: tc.bg,
          borderRadius: BorderRadius.circular(6),
          border: Border(
            left: BorderSide(color: tc.text, width: 4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              event.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: availableHeight < 32 ? 10 : 12,
                fontWeight: FontWeight.bold,
                color: tc.text,
              ),
            ),

            if (showTime) ...[
              const SizedBox(height: 2),
              Text(
                '${_fmt(event.start)} - ${_fmt(event.end)}',
                style: TextStyle(
                  fontSize: 10,
                  color: tc.text.withOpacity(0.8),
                ),
              ),
            ],

            if (showJoin &&
                event.meetingLink != null &&
                event.meetingLink!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Join',
                style: TextStyle(
                  fontSize: 10,
                  color: tc.text,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


/// ─────────────────────────────────────────────────────────
/// COMPACT CHIP → Used inside month / week calendar cells
/// ─────────────────────────────────────────────────────────
class EventChipCompact extends StatelessWidget {
  final EventEntity event;
  final VoidCallback onTap;

  const EventChipCompact({
    super.key,
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tc = EventTypeColor.of(event.eventType);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 20,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: tc.bg,
          borderRadius: BorderRadius.circular(4),
          border: Border(
            left: BorderSide(color: tc.text, width: 3),
          ),
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          '${_fmt(event.start)}  ${event.title}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: tc.text,
          ),
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────
/// Shared time formatter
/// ─────────────────────────────────────────────────────────
String _fmt(DateTime dt) {
  final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final m = dt.minute.toString().padLeft(2, '0');
  final ampm = dt.hour >= 12 ? 'PM' : 'AM';
  return '$h:$m $ampm';
}
