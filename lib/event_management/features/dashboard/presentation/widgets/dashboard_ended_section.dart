import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/event_management/core/utils/event_instant.dart';
import 'package:my_app/event_management/features/events/domain/entities/event.dart';
import 'package:my_app/event_management/features/events/presentation/screens/event_detail_screen.dart';

import '../../shared/dashboard_ui_theme.dart';

class DashboardEndedSection extends StatelessWidget {
  final List<Event> endedEvents;

  const DashboardEndedSection({super.key, required this.endedEvents});

  @override
  Widget build(BuildContext context) {
    if (endedEvents.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 22,
                decoration: BoxDecoration(
                  color: DashboardUiTheme.statEnded,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Ended Today',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: DashboardUiTheme.textDark,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: DashboardUiTheme.statEndedLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${endedEvents.length}',
                  style: const TextStyle(
                    color: DashboardUiTheme.statEnded,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...endedEvents.take(3).map((e) => _EndedEventCard(event: e)),
        ],
      ),
    );
  }
}

class _EndedEventCard extends StatelessWidget {
  final Event event;

  const _EndedEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final start = event.startTime.toLocal();
    final accent = DashboardUiTheme.eventAccent(event.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DashboardUiTheme.statEndedLight,
        borderRadius: BorderRadius.circular(DashboardUiTheme.cardRadius),
        border: Border.all(
          color: DashboardUiTheme.statEnded.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: DashboardUiTheme.cardBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: DashboardUiTheme.border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('MMM').format(start).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: DashboardUiTheme.textMuted,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${start.day}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: DashboardUiTheme.textDark,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: DashboardUiTheme.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: DashboardUiTheme.textMuted.withValues(alpha: 0.9),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      EventInstant.formatTimeRange(
                        event.startTime,
                        event.endTime,
                        allDay: event.isAllDay,
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        color: DashboardUiTheme.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        event.type.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: accent,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => EventDetailScreen(eventId: event.id),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: DashboardUiTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Review',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
