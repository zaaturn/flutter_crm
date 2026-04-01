import 'package:flutter/material.dart';
import 'package:my_app/event_management/core/utils/event_instant.dart';

import 'package:my_app/event_management/features/events/domain/entities/event.dart';
import 'week_view.dart';

class DayView extends StatelessWidget {
  final DateTime selectedDate;
  final List<Event> events;
  final void Function(DateTime) onSlotTapped;

  const DayView({
    required this.selectedDate,
    required this.events,
    required this.onSlotTapped,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final dayEvents = events
        .where((e) => EventInstant.isSameLocalDay(e.startTime, selectedDate))
        .toList();

    return TimeGrid(
      days: [selectedDate],
      events: dayEvents,
      onSlotTapped: onSlotTapped,
    );
  }
}