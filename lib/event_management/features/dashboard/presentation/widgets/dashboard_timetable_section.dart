import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:my_app/event_management/features/events/domain/entities/event.dart';
import 'package:my_app/event_management/features/events/presentation/screens/event_detail_screen.dart';
import '../../shared/dashboard_ui_theme.dart';

/// Today's schedule — flat on page surface (no white card).
class DashboardTimetableSection extends StatelessWidget {
  const DashboardTimetableSection({
    super.key,
    required this.events,
  });

  final List<Event> events;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final sorted = List<Event>.from(events)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 22,
              decoration: BoxDecoration(
                color: DashboardUiTheme.statToday,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Today, ${DateFormat('EEEE, MMM d').format(now)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: DashboardUiTheme.textDark,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: DashboardUiTheme.statTodayLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${sorted.length} event${sorted.length == 1 ? '' : 's'}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: DashboardUiTheme.statToday,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (sorted.isEmpty)
          Text(
            'Nothing scheduled for today.',
            style: TextStyle(
              color: DashboardUiTheme.textMuted.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          )
        else
          for (var i = 0; i < sorted.length && i < 8; i++)
            _TodaySurfaceRow(
              event: sorted[i],
              showDivider: i < sorted.length - 1 && i < 7,
            ),
      ],
    );
  }
}

class _TodaySurfaceRow extends StatelessWidget {
  const _TodaySurfaceRow({
    required this.event,
    this.showDivider = true,
  });

  final Event event;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final start = event.startTime.toLocal();
    final end = event.endTime.toLocal();
    final time = event.isAllDay
        ? 'All day'
        : DateFormat('hh:mm a').format(start);
    final duration = event.isAllDay
        ? ''
        : '${end.difference(start).inMinutes} min';
    final accent = DashboardUiTheme.eventAccent(event.type);
    final fill = DashboardUiTheme.eventFill(event.type);
    final loc = (event.location ?? '').trim();
    final meta = loc.isNotEmpty
        ? loc
        : ((event.meetingLink ?? '').trim().isNotEmpty
            ? 'Google Meet'
            : event.type.label);

    return Column(
      children: [
        InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => EventDetailScreen(eventId: event.id),
            ),
          ),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 72,
                  child: Text(
                    time,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: DashboardUiTheme.textMuted,
                    ),
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: fill,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    DashboardUiTheme.eventIcon(event.type),
                    size: 18,
                    color: accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: DashboardUiTheme.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        meta,
                        style: const TextStyle(
                          fontSize: 12,
                          color: DashboardUiTheme.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (event.description.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          event.description.trim(),
                          style: TextStyle(
                            fontSize: 11,
                            color: DashboardUiTheme.textMuted
                                .withValues(alpha: 0.85),
                            fontWeight: FontWeight.w500,
                            height: 1.35,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (duration.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        event.type.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: accent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        duration,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: DashboardUiTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: DashboardUiTheme.textMuted.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: DashboardUiTheme.border.withValues(alpha: 0.55),
          ),
      ],
    );
  }
}
