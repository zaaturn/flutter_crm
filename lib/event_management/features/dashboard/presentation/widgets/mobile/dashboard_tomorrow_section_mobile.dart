import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/event_management/features/events/domain/entities/event.dart';
import 'package:my_app/event_management/features/events/presentation/screens/mobile/event_detail_screen_mobile.dart';
import 'package:my_app/event_management/features/dashboard/shared/dashboard_ui_theme.dart';

/// Tomorrow's schedule — flat on mint surface (no white card).
class DashboardTomorrowSectionMobile extends StatelessWidget {
  const DashboardTomorrowSectionMobile({super.key, required this.upcoming});

  final List<Event> upcoming;

  @override
  Widget build(BuildContext context) {
    final tomorrow = DateTime.now().toLocal().add(const Duration(days: 1));
    final list = upcoming
        .where((e) => _isSameDay(e.startTime.toLocal(), tomorrow))
        .toList()
      ..sort((a, b) => a.startTime.toLocal().compareTo(b.startTime.toLocal()));

    return Padding(
      padding: const EdgeInsets.only(top: 36),
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
              Expanded(
                child: Text(
                  'Tomorrow, ${DateFormat('EEE, MMM d').format(tomorrow)}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: DashboardUiTheme.textDark,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: DashboardUiTheme.statUpcomingLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${list.length}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: DashboardUiTheme.statUpcoming,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (list.isEmpty)
            Text(
              'Nothing scheduled for tomorrow.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: DashboardUiTheme.textMuted.withValues(alpha: 0.9),
              ),
            )
          else
            ...list.map(
              (e) => _TomorrowSurfaceRowMobile(
                event: e,
                showDivider: e != list.last,
              ),
            ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _TomorrowSurfaceRowMobile extends StatelessWidget {
  const _TomorrowSurfaceRowMobile({
    required this.event,
    this.showDivider = true,
  });

  final Event event;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final start = event.startTime.toLocal();
    final end = event.endTime.toLocal();
    final time =
        event.isAllDay ? 'All day' : DateFormat('hh:mm a').format(start);
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
              builder: (_) => EventDetailMobileScreen(eventId: event.id),
            ),
          ),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 64,
                  child: Text(
                    time,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: DashboardUiTheme.textMuted,
                    ),
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: fill,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    DashboardUiTheme.eventIcon(event.type),
                    size: 16,
                    color: accent,
                  ),
                ),
                const SizedBox(width: 10),
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
                      const SizedBox(height: 2),
                      Text(
                        meta,
                        style: const TextStyle(
                          fontSize: 11,
                          color: DashboardUiTheme.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (event.description.trim().isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          event.description.trim(),
                          style: TextStyle(
                            fontSize: 10,
                            color: DashboardUiTheme.textMuted
                                .withValues(alpha: 0.85),
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (duration.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 6, top: 2),
                    child: Text(
                      duration,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: DashboardUiTheme.textMuted,
                      ),
                    ),
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
