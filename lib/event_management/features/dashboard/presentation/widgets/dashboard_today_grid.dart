import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/event_management/features/events/domain/entities/event.dart';
import 'package:my_app/event_management/features/events/presentation/screens/event_detail_screen.dart';

import '../../shared/dashboard_ui_theme.dart';

class DashboardTodayGrid extends StatelessWidget {
  final List<Event> events;
  final EdgeInsetsGeometry sectionPadding;

  const DashboardTodayGrid({
    super.key,
    required this.events,
    this.sectionPadding = const EdgeInsets.fromLTRB(20, 20, 20, 0),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: sectionPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: "Today's Events",
            trailing: events.isNotEmpty
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
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
                  )
                : null,
          ),
          const SizedBox(height: 14),
          if (events.isEmpty)
            _emptyState('You’re all caught up for today.')
          else
            LayoutBuilder(
              builder: (context, c) {
                final cols = c.maxWidth >= 720 ? 2 : 1;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    mainAxisExtent: 96,
                  ),
                  itemCount: events.take(6).length,
                  itemBuilder: (_, i) => _TodayCard(event: events[i]),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _emptyState(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: DashboardUiTheme.cardDecoration(),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: DashboardUiTheme.statTodayLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: DashboardUiTheme.statToday,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            msg,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: DashboardUiTheme.textMuted,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            color: DashboardUiTheme.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: DashboardUiTheme.textDark,
            letterSpacing: -0.3,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 10),
          trailing!,
        ],
      ],
    );
  }
}

class _TodayCard extends StatelessWidget {
  final Event event;
  const _TodayCard({required this.event});

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
          MaterialPageRoute(builder: (_) => EventDetailScreen(eventId: event.id)),
        ),
        borderRadius: BorderRadius.circular(DashboardUiTheme.cardRadiusSm),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(DashboardUiTheme.cardRadiusSm),
            border: Border.all(color: accent.withValues(alpha: 0.2)),
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        _TypePill(label: event.type.label, color: accent),
                      ],
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
                                fontWeight: FontWeight.w500,
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
            ],
          ),
        ),
      ),
    );
  }
}

class _TypePill extends StatelessWidget {
  const _TypePill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: DashboardUiTheme.cardBackground.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
