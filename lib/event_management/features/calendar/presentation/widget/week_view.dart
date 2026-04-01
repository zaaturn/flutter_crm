import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/event_management/core/utils/event_instant.dart';
import 'package:my_app/event_management/features/events/domain/entities/event.dart';
import 'package:my_app/event_management/features/events/presentation/screens/event_detail_screen.dart';
import 'package:my_app/event_management/shared/themes/app_theme.dart';
import 'package:table_calendar/table_calendar.dart';

class WeekView extends StatelessWidget {
  final DateTime selectedDate;
  final List<Event> events;
  final void Function(DateTime) onDayTapped;

  const WeekView({
    required this.selectedDate,
    required this.events,
    required this.onDayTapped,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final weekStart = selectedDate.subtract(
      Duration(days: selectedDate.weekday - 1),
    );
    final days = List.generate(7, (i) => weekStart.add(Duration(days: i)));

    return Column(
      children: [
        // Day header row
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(
              bottom: BorderSide(color: AppTheme.borderLight),
            ),
          ),
          child: Row(
            children: days.map((day) {
              final isToday = isSameDay(day, DateTime.now());
              final isSelected = isSameDay(day, selectedDate);
              return Expanded(
                child: GestureDetector(
                  onTap: () => onDayTapped(day),
                  child: Column(
                    children: [
                      Text(
                        DateFormat.E().format(day),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryBlue
                              : isToday
                              ? AppTheme.primaryBlue.withOpacity(0.1)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : isToday
                                  ? AppTheme.primaryBlue
                                  : AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        // Time grid
        Expanded(
          child: TimeGrid(
            days: days,
            events: events,
            onSlotTapped: onDayTapped,
          ),
        ),
      ],
    );
  }
}

/// Reusable time grid used by both WeekView and DayView
class TimeGrid extends StatelessWidget {
  final List<DateTime> days;
  final List<Event> events;
  final void Function(DateTime) onSlotTapped;

  const TimeGrid({
    required this.days,
    required this.events,
    required this.onSlotTapped,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        height: 24 * 60.0, // 60px per hour
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hour labels
            SizedBox(
              width: 52,
              child: Column(
                children: List.generate(24, (hour) {
                  return SizedBox(
                    height: 60,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8, top: 4),
                      child: Text(
                        DateFormat.jm().format(
                          DateTime(2000, 1, 1, hour),
                        ),
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textHint,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            // Day columns
            ...days.map((day) {
              final dayEvents = events
                  .where((e) => EventInstant.isSameLocalDay(e.startTime, day))
                  .toList();
              return Expanded(
                child: GestureDetector(
                  onTapUp: (details) {
                    final hour =
                    (details.localPosition.dy / 60).floor().clamp(0, 23);
                    onSlotTapped(
                      DateTime(day.year, day.month, day.day, hour),
                    );
                  },
                  child: Stack(
                    children: [
                      // Hour lines
                      Column(
                        children: List.generate(
                          24,
                              (_) => Container(
                            height: 60,
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: AppTheme.borderLight,
                                  width: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Current time indicator
                      if (isSameDay(day, DateTime.now()))
                        Positioned(
                          top: (DateTime.now().hour * 60 +
                              DateTime.now().minute)
                              .toDouble(),
                          left: 0,
                          right: 0,
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 1.5,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      // Event blocks
                      ...dayEvents.map((e) => _EventBlock(event: e)),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _EventBlock extends StatelessWidget {
  final Event event;
  const _EventBlock({required this.event});

  @override
  Widget build(BuildContext context) {
    final local = event.startTime.toLocal();
    final top = (local.hour * 60 + local.minute).toDouble();
    final height = event.duration.inMinutes.clamp(20, 1440).toDouble();
    final color = Color(
      int.parse('0xFF${event.displayColor.replaceAll('#', '')}'),
    );

    return Positioned(
      top: top,
      left: 2,
      right: 2,
      height: height,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push<void>(
            MaterialPageRoute<void>(
              builder: (_) => EventDetailScreen(eventId: event.id),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            border: Border(left: BorderSide(color: color, width: 3)),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(6),
              bottomRight: Radius.circular(6),
            ),
          ),
          child: Text(
            event.title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            maxLines: height > 40 ? 2 : 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}