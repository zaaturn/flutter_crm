import 'package:flutter/material.dart';
import 'package:my_app/event_management/features/events/domain/entities/event.dart';
import 'package:my_app/event_management/features/events/presentation/widgets/event_card_mobile.dart';
import 'package:my_app/event_management/features/dashboard/shared/dashboard_ui_theme.dart';

class DashboardUpcomingSectionMobile extends StatelessWidget {
  final List<Event> upcoming;
  final int maxItems;

  const DashboardUpcomingSectionMobile({
    super.key,
    required this.upcoming,
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
      ..sort((a, b) => b.startTime.toLocal().compareTo(a.startTime.toLocal()));

    final shown = list.take(maxItems).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
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
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pushNamed('/calendar'),
                style: TextButton.styleFrom(
                  foregroundColor: DashboardUiTheme.primary,
                ),
                child: const Text(
                  'Calendar',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (shown.isEmpty)
            _buildEmptyState()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: shown.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) => EventCardMobile(
                event: shown[i],
                compact: true,
              ),
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
        'No upcoming events.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: DashboardUiTheme.textMuted,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
