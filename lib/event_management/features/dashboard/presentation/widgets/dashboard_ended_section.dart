import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/event_management/core/utils/event_instant.dart';
import 'package:my_app/event_management/features/events/domain/entities/event.dart';
import 'package:my_app/event_management/features/events/presentation/screens/event_detail_screen.dart';
import 'package:my_app/event_management/shared/themes/app_theme.dart';

class DashboardEndedSection extends StatelessWidget {
  final List<Event> endedEvents;

  const DashboardEndedSection({super.key, required this.endedEvents});

  @override
  Widget build(BuildContext context) {
    if (endedEvents.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Ended',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${endedEvents.length}',
                  style: const TextStyle(
                    color: Color(0xFFDC2626),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
    final color = Color(int.parse('0xFF${event.displayColor.replaceAll('#', '')}'));

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFCECEC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFAD1D1)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF3E8FF), width: 0.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('MMM').format(start).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textHint,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${start.day}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimary,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        event.type.label.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: color,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded,
                        size: 14, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      EventInstant.formatTimeRange(
                        event.startTime,
                        event.endTime,
                        allDay: event.isAllDay,
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if ((event.meetingLink ?? '').isNotEmpty) ...[
                      const SizedBox(width: 10),
                      const Icon(Icons.videocam_outlined,
                          size: 14, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      const Text(
                        'Meeting',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => EventDetailScreen(eventId: event.id),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              foregroundColor: AppTheme.textPrimary,
              side: BorderSide(color: AppTheme.borderLight.withValues(alpha: 0.9)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: const Text(
              'Review',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

