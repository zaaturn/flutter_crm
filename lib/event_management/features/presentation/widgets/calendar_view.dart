import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:my_app/event_management/core/constants/app_colors.dart';

import '../../domain/entities/event_entity.dart';
import 'event_chip.dart';

class CalendarView extends StatefulWidget {
  final List<EventEntity> events;
  // --- ADDED PARAMETERS TO MATCH SCREEN CALL ---
  final CalendarFormat format;
  final DateTime focusedDay;
  // ---------------------------------------------
  final void Function(DateTime) onDayTapped;
  final void Function(EventEntity) onEventTapped;

  const CalendarView({
    super.key,
    required this.events,
    required this.format,     // Required in constructor
    required this.focusedDay, // Required in constructor
    required this.onDayTapped,
    required this.onEventTapped,
  });

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  // Removed internal _focusedDay and _calendarFormat to use widget.focusedDay and widget.format
  DateTime? _selectedDay;

  Map<DateTime, List<EventEntity>> get _eventMap {
    final map = <DateTime, List<EventEntity>>{};
    for (final ev in widget.events) {
      final key = _normaliseDate(ev.start);
      (map[key] ??= []).add(ev);
    }
    return map;
  }

  List<EventEntity> _getEventsForDay(DateTime day) =>
      _eventMap[_normaliseDate(day)] ?? [];

  static DateTime _normaliseDate(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        _viewSwitcher(theme),
        const SizedBox(height: 8),

        TableCalendar<EventEntity>(
          firstDay: DateTime(2020, 1, 1),
          lastDay: DateTime(2030, 12, 31),
          // Use widget props passed from BLoC
          focusedDay: widget.focusedDay,
          calendarFormat: widget.format,

          selectedDayPredicate: (day) =>
          _selectedDay != null && isSameDay(_selectedDay, day),

          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
            });

            final evs = _getEventsForDay(selectedDay);
            if (evs.isEmpty) {
              widget.onDayTapped(
                selectedDay.copyWith(hour: 9, minute: 0),
              );
            }
          },

          // These are now handled via your Screen/BLoC logic
          onFormatChanged: (format) => {},
          onPageChanged: (focusedDay) => {},

          eventLoader: _getEventsForDay,

          calendarStyle: const CalendarStyle(
            todayDecoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            todayTextStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            selectedDecoration: BoxDecoration(
              color: Color(0x266366F1), // Primary with 15% alpha
              shape: BoxShape.circle,
              border: Border.fromBorderSide(BorderSide(color: AppColors.primary, width: 2)),
            ),
            selectedTextStyle: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
            outsideTextStyle: TextStyle(color: AppColors.textLight),
            markerDecoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            markersAlignment: Alignment.bottomCenter,
          ),

          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            // Desktop logic handled the title in TopBar,
            // but mobile often uses this header or a custom one.
            titleTextStyle: theme.textTheme.titleLarge ?? const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            leftChevronIcon: const Icon(Icons.chevron_left, color: AppColors.textMuted),
            rightChevronIcon: const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ),

          daysOfWeekStyle: const DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
            weekendStyle: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ),

        const SizedBox(height: 12),
        const Divider(height: 1, color: AppColors.border),
        const SizedBox(height: 10),
        Expanded(child: SingleChildScrollView(child: _eventList())),
      ],
    );
  }

  Widget _viewSwitcher(ThemeData theme) {
    final formats = [
      _ViewOption('Month', CalendarFormat.month),
      _ViewOption('Week', CalendarFormat.twoWeeks),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Row(
            children: formats.map((opt) {
              final isActive = opt.format == widget.format;
              return GestureDetector(
                onTap: () {
                  // In a full BLoC setup, you'd emit an event here to change format
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  color: isActive ? AppColors.primary : const Color(0xFFFAFBFC),
                  child: Text(
                    opt.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isActive ? Colors.white : AppColors.textMuted,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _eventList() {
    final day = _selectedDay ?? widget.focusedDay;
    final evs = _getEventsForDay(day);

    if (evs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            'No events for this day',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: evs
            .map((ev) => EventChip(
          event: ev,
          onTap: () => widget.onEventTapped(ev),
        ))
            .toList(),
      ),
    );
  }
}

class _ViewOption {
  final String label;
  final CalendarFormat format;
  const _ViewOption(this.label, this.format);
}