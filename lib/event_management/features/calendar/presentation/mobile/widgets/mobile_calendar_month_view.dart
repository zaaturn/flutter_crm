import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/calendar_grid_event.dart';
import '../../../shared/calendar_date_utils.dart';
import '../../../shared/calendar_palette.dart';
import '../mobile_calendar_theme.dart';
import 'mobile_event_card.dart';

/// Month grid — one month only (no previous/next month dates in cells).
class MobileCalendarMonthView extends StatelessWidget {
  const MobileCalendarMonthView({
    super.key,
    required this.focusedMonth,
    required this.selectedDate,
    required this.events,
    required this.dotMap,
    required this.onDayTap,
    required this.onEventTap,
  });

  final DateTime focusedMonth;
  final DateTime selectedDate;
  final List<CalendarGridEvent> events;
  final Map<String, List<String>> dotMap;
  final ValueChanged<DateTime> onDayTap;
  final ValueChanged<CalendarGridEvent> onEventTap;

  /// Leading/trailing empty cells keep weekday columns aligned; only in-month days are tappable.
  List<DateTime?> _monthCells() {
    final first = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final daysInMonth = DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;
    final leading = first.weekday % 7;
    final cells = <DateTime?>[];

    for (var i = 0; i < leading; i++) {
      cells.add(null);
    }
    for (var d = 1; d <= daysInMonth; d++) {
      cells.add(DateTime(focusedMonth.year, focusedMonth.month, d));
    }
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    return cells;
  }

  List<CalendarGridEvent> _eventsForDay(DateTime day) {
    return events
        .where((e) {
          final s = e.startTime.toLocal();
          return CalendarDateUtils.isSameDay(
            DateTime(s.year, s.month, s.day),
            day,
          );
        })
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  @override
  Widget build(BuildContext context) {
    final cells = _monthCells();
    final rowCount = cells.length ~/ 7;
    final dayEvents = _eventsForDay(selectedDate);
    final header = DateFormat('EEE, MMM d').format(selectedDate);
    final today = CalendarDateUtils.dateOnly(DateTime.now());

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map(
                  (w) => Expanded(
                    child: Center(
                      child: Text(
                        w,
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: MobileCalendarTheme.textMuted,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisExtent: 52,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
            ),
            itemCount: cells.length,
            itemBuilder: (context, index) {
              final day = cells[index];
              if (day == null) {
                return const SizedBox.shrink();
              }

              final selected = CalendarDateUtils.isSameDay(day, selectedDate);
              final isToday = CalendarDateUtils.isSameDay(day, today);
              final key = CalendarDateUtils.dateKey(day);
              final dots = dotMap[key] ?? const [];

              return GestureDetector(
                onTap: () => onDayTap(day),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: selected ? MobileCalendarTheme.selectedCell : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected
                              ? MobileCalendarTheme.terracotta
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          border: isToday && !selected
                              ? Border.all(
                                  color: MobileCalendarTheme.terracotta,
                                  width: 1.5,
                                )
                              : null,
                        ),
                        child: Text(
                          '${day.day}',
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: selected
                                ? Colors.white
                                : MobileCalendarTheme.textDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      SizedBox(
                        height: 6,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: dots.take(4).map((t) {
                            final c = CalendarPalette.dotColor(t) ??
                                MobileCalendarTheme.task;
                            return Container(
                              width: 5,
                              height: 5,
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              decoration: BoxDecoration(
                                color: c,
                                shape: BoxShape.circle,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: rowCount > 5 ? 4 : 8),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
            children: [
              Text(
                header,
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: MobileCalendarTheme.textMuted,
                ),
              ),
              const SizedBox(height: 10),
              if (dayEvents.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Center(
                    child: Text(
                      'No events this day',
                      style: GoogleFonts.manrope(
                        color: MobileCalendarTheme.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              else
                ...dayEvents.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: MobileEventCard(
                      event: e,
                      onTap: () => onEventTap(e),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
