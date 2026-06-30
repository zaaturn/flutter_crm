import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/event_management/features/events/domain/entities/event.dart';
import 'package:my_app/event_management/features/events/presentation/screens/mobile/event_detail_screen_mobile.dart';
import 'package:my_app/event_management/features/dashboard/shared/dashboard_ui_theme.dart';

class DashboardTodayGridMobile extends StatelessWidget {
  final List<Event> events;

  const DashboardTodayGridMobile({
    super.key,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
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
                  color: DashboardUiTheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "Today's Events",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: DashboardUiTheme.textDark,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              if (events.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: DashboardUiTheme.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${events.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: DashboardUiTheme.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (events.isEmpty)
            _buildEmptyState()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events.take(5).length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _TodayMobileCard(event: events[i]),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: DashboardUiTheme.cardDecoration(),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: DashboardUiTheme.statTodayLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.spa_rounded,
              color: DashboardUiTheme.statToday,
              size: 26,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "You're all caught up for today.",
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

class _TodayMobileCard extends StatelessWidget {
  final Event event;
  const _TodayMobileCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final fill = DashboardUiTheme.eventFill(event.type);
    final textColor = DashboardUiTheme.eventText(event.type);
    final accent = DashboardUiTheme.eventAccent(event.type);
    final start = event.startTime.toLocal();
    final time = event.isAllDay ? 'All day' : DateFormat.jm().format(start);
    final loc = (event.location ?? '').trim();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => EventDetailMobileScreen(eventId: event.id),
          ),
        ),
        borderRadius: BorderRadius.circular(DashboardUiTheme.cardRadius),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(DashboardUiTheme.cardRadius),
            border: Border.all(color: accent.withValues(alpha: 0.22)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: DashboardUiTheme.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  DashboardUiTheme.eventIcon(event.type),
                  color: accent,
                  size: 20,
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
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 13,
                          color: textColor.withValues(alpha: 0.65),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 12,
                            color: textColor.withValues(alpha: 0.75),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (loc.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              loc,
                              style: TextStyle(
                                fontSize: 11,
                                color: textColor.withValues(alpha: 0.6),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: textColor.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
