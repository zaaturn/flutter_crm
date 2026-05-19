import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:my_app/event_management/core/utils/event_instant.dart';
import 'package:my_app/event_management/features/calendar/presentation/bloc/calender_state.dart';
import 'package:my_app/event_management/features/events/domain/entities/event.dart';
import 'package:my_app/event_management/features/events/presentation/screens/event_detail_screen.dart';
import 'package:my_app/event_management/features/events/presentation/widgets/quick_add_sheet.dart';
import 'package:my_app/event_management/shared/themes/event_colors.dart';
import 'package:my_app/event_management/shared/themes/event_adaptive_theme.dart';

class MonthView extends StatelessWidget {
  final CalendarState calState;
  final List<Event> events;
  final void Function(DateTime) onDaySelected;
  final void Function(DateTime) onMonthChanged;
  final BuildContext rootContext;

  const MonthView({
    required this.calState,
    required this.events,
    required this.onDaySelected,
    required this.onMonthChanged,
    required this.rootContext,
    super.key,
  });

  List<Event> _eventsForDay(DateTime day) => events
      .where((e) => EventInstant.isSameLocalDay(e.startTime, day))
      .toList();

  @override
  Widget build(BuildContext context) {
    final showDayPanel = MediaQuery.sizeOf(context).width < 900;

    return Container(
      color: EventAdaptiveTheme.bg(context),
      child: Column(
        children: [
          Flexible(
            flex: showDayPanel ? 6 : 1,
            child: LayoutBuilder(
              builder: (context, c) {
                // Fit calendar cells for mobile. Typical month has 6 rows.
                final available = c.maxHeight;
                const dowH = 36.0;
                // Conservative sizing to avoid bottom overflow on small devices
                // (calendar header/toolbars + day panel + bottom nav).
                final rawRow = ((available - dowH) / 6).clamp(46.0, 74.0);

                return TableCalendar<Event>(
                  firstDay: DateTime(2020),
                  lastDay: DateTime(2030),
                  focusedDay: calState.focusedMonth,
                  selectedDayPredicate: (d) => isSameDay(d, calState.selectedDate),
                  eventLoader: _eventsForDay,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  rowHeight: rawRow,

                  onDaySelected: (selected, _) => onDaySelected(selected),
                  onDayLongPressed: (selected, _) => onDaySelected(selected),
                  onPageChanged: onMonthChanged,

                  // ── Calendar style ───────────────────────────────────────────
                  calendarStyle: const CalendarStyle(
                    outsideDaysVisible: true,
                    defaultDecoration: BoxDecoration(),
                    weekendDecoration: BoxDecoration(),
                    selectedDecoration: BoxDecoration(),
                    todayDecoration: BoxDecoration(),
                    outsideDecoration: BoxDecoration(),
                    markerSize: 0,
                    markersMaxCount: 0,
                    cellMargin: EdgeInsets.zero,
                    cellPadding: EdgeInsets.zero,
                  ),

                  headerVisible: false,

                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: EventAdaptiveTheme.muted(context),
                      letterSpacing: 0.2,
                    ),
                    weekendStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: EventAdaptiveTheme.muted(context),
                      letterSpacing: 0.2,
                    ),
                    dowTextFormatter: (date, locale) =>
                        DateFormat.E(locale).format(date),
                  ),

                  daysOfWeekHeight: dowH,

                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (ctx, day, focusedDay) => _DayCell(
                      day: day,
                      events: _eventsForDay(day),
                      isSelected: isSameDay(day, calState.selectedDate),
                      isToday: isSameDay(day, DateTime.now()),
                      isOutside: false,
                      onTap: () => onDaySelected(day),
                    ),
                    selectedBuilder: (ctx, day, focusedDay) => _DayCell(
                      day: day,
                      events: _eventsForDay(day),
                      isSelected: true,
                      isToday: isSameDay(day, DateTime.now()),
                      isOutside: false,
                      onTap: () => onDaySelected(day),
                    ),
                    todayBuilder: (ctx, day, focusedDay) => _DayCell(
                      day: day,
                      events: _eventsForDay(day),
                      isSelected: isSameDay(day, calState.selectedDate),
                      isToday: true,
                      isOutside: false,
                      onTap: () => onDaySelected(day),
                    ),
                    outsideBuilder: (ctx, day, focusedDay) => _DayCell(
                      day: day,
                      events: _eventsForDay(day),
                      isSelected: false,
                      isToday: false,
                      isOutside: true,
                      onTap: () {},
                    ),
                    disabledBuilder: (ctx, day, focusedDay) => _DayCell(
                      day: day,
                      events: const [],
                      isSelected: false,
                      isToday: false,
                      isOutside: true,
                      onTap: () {},
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Divider ────────────────────────────────────────────────────────
          if (showDayPanel) ...[
            Divider(
              height: 1,
              thickness: 0.5,
              color: EventAdaptiveTheme.border(context).withValues(alpha: 0.7),
            ),
            Flexible(
              flex: 4,
              child: _DayPanel(
                date: calState.selectedDate ?? DateTime.now(),
                events: _eventsForDay(calState.selectedDate ?? DateTime.now()),
                rootContext: rootContext,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Square Day Cell ────────────────────────────────────────────────────────────

class _DayCell extends StatelessWidget {
  final DateTime day;
  final List<Event> events;
  final bool isSelected;
  final bool isToday;
  final bool isOutside;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.events,
    required this.isSelected,
    required this.isToday,
    required this.isOutside,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final day = this.day;
    final events = this.events;
    final isOutside = this.isOutside;
    final isSelected = this.isSelected;
    final isToday = this.isToday;

    final isWeekend =
        day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;

    const gridLine = Color(0xFFE5E7EB);
    Color numColor;
    if (isOutside) {
      numColor = const Color(0xFF9CA3AF);
    } else if (isWeekend) {
      numColor = isSelected ? const Color(0xFF1D4ED8) : const Color(0xFF374151);
    } else {
      numColor = isSelected
          ? const Color(0xFF1D4ED8)
          : isToday
          ? const Color(0xFF2563EB)
          : const Color(0xFF111827);
    }

    Color cellBg;
    if (isSelected) {
      cellBg = const Color(0xFFEFF6FF);
    } else if (isOutside) {
      cellBg = const Color(0xFFF9FAFB);
    } else {
      cellBg = Colors.white;
    }

    final numBadgeBg = isToday && !isSelected
        ? const Color(0xFF2563EB)
        : Colors.transparent;

    final numBadgeFg = (isToday && !isSelected) ? Colors.white : numColor;

    return GestureDetector(
      onTap: isOutside ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: cellBg,
          border: const Border(
            top: BorderSide(color: gridLine, width: 1),
            left: BorderSide(color: gridLine, width: 1),
          ),
        ),
        // Slightly tighter top padding to match the design and avoid overflow.
        padding: const EdgeInsets.fromLTRB(5, 4, 4, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: numBadgeBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${day.day}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: numBadgeFg,
                  height: 1,
                ),
              ),
            ),
            const SizedBox(height: 2),
            if (!isOutside)
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  physics: const ClampingScrollPhysics(),
                  itemCount: events.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 2),
                  itemBuilder: (_, i) => _EventPill(event: events[i]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Inline event pill inside a day cell ────────────────────────────────────────

class _EventPill extends StatelessWidget {
  final Event event;
  const _EventPill({required this.event});

  @override
  Widget build(BuildContext context) {
    final fill = EventColors.chipFillForEvent(event);
    final tc = EventColors.chipTextForEvent(event);

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push<void>(
            MaterialPageRoute<void>(
              builder: (_) => EventDetailScreen(eventId: event.id),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            event.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: tc,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Day Panel — events list for selected date ──────────────────────────────────

class _DayPanel extends StatelessWidget {
  final DateTime date;
  final List<Event> events;
  final BuildContext rootContext;

  const _DayPanel({
    required this.date,
    required this.events,
    required this.rootContext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = EventAdaptiveTheme.primary(context);
    final muted = EventAdaptiveTheme.muted(context);
    final border = EventAdaptiveTheme.border(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Panel header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 16, 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  DateFormat('EEEE, MMMM d').format(date),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Add event button
              TextButton.icon(
                onPressed: () => QuickAddSheet.show(rootContext, date),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add event'),
                style: TextButton.styleFrom(
                  foregroundColor: primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: border.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1, thickness: 0.5),

        // Events
        if (events.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.event_note_outlined,
                    size: 40,
                    color: muted.withValues(alpha: 0.55),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'No events scheduled',
                    style: TextStyle(
                      fontSize: 14,
                      color: muted,
                    ),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: () => QuickAddSheet.show(rootContext, date),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Schedule event'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primary,
                      side: BorderSide(
                        color: border.withValues(alpha: 0.7),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: events.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (ctx, i) => _DayEventRow(event: events[i]),
            ),
          ),
      ],
    );
  }
}

// ── Single event row in the day panel ─────────────────────────────────────────

class _DayEventRow extends StatelessWidget {
  final Event event;
  const _DayEventRow({required this.event});

  @override
  Widget build(BuildContext context) {
    final solid = EventColors.solid(event.type);
    final bg = EventColors.background(event.type);
    final tc = EventColors.text(event.type);
    final theme = Theme.of(context);
    final surface = EventAdaptiveTheme.surface(context);

    return Container(
      decoration: BoxDecoration(
        color: surface,
        border: Border(left: BorderSide(color: solid, width: 3)),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        dense: true,
        title: Text(
          event.title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          event.isAllDay
              ? 'All day'
              : '${EventInstant.formatTimeRange(event.startTime, event.endTime)}'
                    '${event.location != null && event.location!.isNotEmpty ? '  ·  ${event.location}' : ''}',
          style: TextStyle(
            fontSize: 11,
            color: EventAdaptiveTheme.muted(context),
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            event.type.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: tc,
            ),
          ),
        ),
        onTap: () {
          Navigator.of(context).push<void>(
            MaterialPageRoute<void>(
              builder: (_) => EventDetailScreen(eventId: event.id),
            ),
          );
        },
      ),
    );
  }
}
