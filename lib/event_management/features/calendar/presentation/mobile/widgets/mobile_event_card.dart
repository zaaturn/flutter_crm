import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/calendar_grid_event.dart';
import '../mobile_calendar_theme.dart';

class MobileEventCard extends StatelessWidget {
  const MobileEventCard({
    super.key,
    required this.event,
    required this.onTap,
    this.showJoin = false,
  });

  final CalendarGridEvent event;
  final VoidCallback onTap;
  final bool showJoin;

  @override
  Widget build(BuildContext context) {
    final strip = MobileCalendarTheme.stripForType(
      event.isTaskDeadline ? 'task' : event.eventType,
    );
    final timeLabel = _timeLabel(event);

    return Material(
      color: MobileCalendarTheme.card,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: MobileCalendarTheme.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ColoredBox(color: strip, child: const SizedBox(width: 4)),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.manrope(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: MobileCalendarTheme.textDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  timeLabel,
                                  style: GoogleFonts.manrope(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: MobileCalendarTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (showJoin &&
                              event.eventType.toLowerCase() == 'meeting')
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8E8E4),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Join',
                                style: GoogleFonts.manrope(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                  color: MobileCalendarTheme.terracotta,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _timeLabel(CalendarGridEvent event) {
    if (event.isAllDay) return 'All day';
    final start = event.startTime.toLocal();
    final end = event.endTime.toLocal();
    final fmt = DateFormat('h:mm a');
    return '${fmt.format(start)} – ${fmt.format(end)}';
  }
}
