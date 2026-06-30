import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/event_management/features/events/domain/entities/event.dart';
import 'package:my_app/event_management/features/events/presentation/screens/event_detail_screen.dart';

import '../../shared/dashboard_ui_theme.dart';

class DashboardUpcomingSection extends StatelessWidget {
  final List<Event> upcoming;
  final EdgeInsetsGeometry sectionPadding;
  final int maxItems;

  const DashboardUpcomingSection({
    super.key,
    required this.upcoming,
    this.sectionPadding = const EdgeInsets.fromLTRB(20, 24, 20, 0),
    this.maxItems = 6,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().toLocal();
    final todayStart = DateTime(now.year, now.month, now.day);

    final list = upcoming.where((e) {
      final local = e.startTime.toLocal();
      final d = DateTime(local.year, local.month, local.day);
      return d.isAfter(todayStart);
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final shown = list.take(maxItems).toList();

    return Padding(
      padding: sectionPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 22,
                decoration: BoxDecoration(
                  color: DashboardUiTheme.statUpcoming,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Upcoming Events',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: DashboardUiTheme.textDark,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pushNamed('/calendar'),
                style: TextButton.styleFrom(
                  foregroundColor: DashboardUiTheme.primary,
                ),
                child: const Text(
                  'View Calendar',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (shown.isEmpty)
            _buildEmptyState()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: shown.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) => _UpcomingRow(event: shown[i]),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: DashboardUiTheme.cardDecoration(),
      child: const Text(
        'No upcoming events scheduled.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: DashboardUiTheme.textMuted,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _UpcomingRow extends StatelessWidget {
  final Event event;
  const _UpcomingRow({required this.event});

  @override
  Widget build(BuildContext context) {
    final start = event.startTime.toLocal();
    final dateLabel = DateFormat('EEE, MMM d').format(start);
    final time = event.isAllDay ? 'All day' : DateFormat.jm().format(start);
    final accent = DashboardUiTheme.eventAccent(event.type);
    final fill = DashboardUiTheme.eventFill(event.type);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => EventDetailScreen(eventId: event.id)),
          );
        },
        borderRadius: BorderRadius.circular(DashboardUiTheme.cardRadiusSm),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: DashboardUiTheme.cardDecoration(),
          child: Row(
            children: [
              Container(
                width: 56,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      dateLabel.split(',').first.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: accent,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: DashboardUiTheme.eventText(event.type),
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
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: DashboardUiTheme.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _subtitle(),
                      style: const TextStyle(
                        fontSize: 11,
                        color: DashboardUiTheme.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: DashboardUiTheme.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  event.type.label,
                  style: TextStyle(
                    color: accent,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _subtitle() {
    final loc = (event.location ?? '').trim();
    if (loc.isNotEmpty) return loc;
    if ((event.meetingLink ?? '').trim().isNotEmpty) return 'Online';
    return 'Scheduled';
  }
}
