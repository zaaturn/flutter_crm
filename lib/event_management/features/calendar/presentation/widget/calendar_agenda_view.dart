import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/calendar_grid_event.dart';
import '../../domain/entities/calendar_holiday.dart';
import '../../shared/calendar_date_utils.dart';
import 'calendar_event_chip.dart';
import 'holiday_chip.dart';

class CalendarAgendaView extends StatefulWidget {
  const CalendarAgendaView({
    super.key,
    required this.events,
    required this.holidaysByDate,
    required this.onEventTap,
  });

  final List<CalendarGridEvent> events;
  final Map<String, List<CalendarHoliday>> holidaysByDate;
  final ValueChanged<CalendarGridEvent> onEventTap;

  @override
  State<CalendarAgendaView> createState() => _CalendarAgendaViewState();
}

class _CalendarAgendaViewState extends State<CalendarAgendaView> {
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final grouped = <DateTime, List<CalendarGridEvent>>{};
    for (final e in widget.events) {
      final d = CalendarDateUtils.dateOnly(e.startTime.toLocal());
      grouped.putIfAbsent(d, () => []).add(e);
    }

    final holidayDates = widget.holidaysByDate.keys
        .map((k) => DateTime.tryParse(k))
        .whereType<DateTime>()
        .map(CalendarDateUtils.dateOnly)
        .toSet();

    final dates = {...grouped.keys, ...holidayDates}.toList()..sort();

    if (dates.isEmpty) {
      return Center(
        child: Text(
          'No events in this range',
          style: TextStyle(color: Colors.grey.shade500),
        ),
      );
    }

    return Scrollbar(
      controller: _scroll,
      thumbVisibility: true,
      interactive: true,
      radius: const Radius.circular(8),
      child: ListView.builder(
        controller: _scroll,
        padding: const EdgeInsets.all(16),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final day = dates[index];
          final key = CalendarDateUtils.dateKey(day);
          final dayHolidays = widget.holidaysByDate[key] ?? const [];
          final items = grouped[day] ?? []
            ..sort((a, b) => a.startTime.compareTo(b.startTime));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 8),
                child: Text(
                  DateFormat('EEEE, MMM d').format(day),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
              ...dayHolidays.map((h) => HolidayAgendaRow(holiday: h)),
              ...items.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: CalendarEventChip(
                    event: e,
                    onTap: () => widget.onEventTap(e),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
