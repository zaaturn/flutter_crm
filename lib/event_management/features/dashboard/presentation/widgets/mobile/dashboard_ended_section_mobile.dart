import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/event_management/features/events/domain/entities/event.dart';
import 'package:my_app/event_management/features/events/presentation/screens/mobile/event_detail_screen_mobile.dart';
import 'package:my_app/event_management/features/dashboard/shared/dashboard_ui_theme.dart';

class DashboardEndedSectionMobile extends StatelessWidget {
  final List<Event> endedEvents;

  const DashboardEndedSectionMobile({super.key, required this.endedEvents});

  @override
  Widget build(BuildContext context) {
    if (endedEvents.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
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
                ),
              ),
              if (endedEvents.isNotEmpty) ...[
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
            ],
          ),
          const SizedBox(height: 14),
          if (endedEvents.isEmpty)
            _buildRelaxState()
          else
            ...endedEvents.take(3).map((e) => _EndedMobileCard(event: e)),
        ],
      ),
    );
  }

  Widget _buildRelaxState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: DashboardUiTheme.cardDecoration(),
      child: const Column(
        children: [
          Icon(
            Icons.sentiment_satisfied_alt_rounded,
            color: DashboardUiTheme.statToday,
            size: 32,
          ),
          SizedBox(height: 8),
          Text(
            'No events ended today — you’re on track.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: DashboardUiTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _EndedMobileCard extends StatelessWidget {
  final Event event;
  const _EndedMobileCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final start = event.startTime.toLocal();
    final accent = DashboardUiTheme.eventAccent(event.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
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
            width: 48,
            height: 48,
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
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: DashboardUiTheme.textDark,
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
                Text(
                  event.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: DashboardUiTheme.textDark.withValues(alpha: 0.7),
                    decoration: TextDecoration.lineThrough,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 14,
                      color: accent.withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      event.type.label,
                      style: TextStyle(
                        fontSize: 12,
                        color: accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => EventDetailMobileScreen(eventId: event.id),
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: DashboardUiTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Review',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
