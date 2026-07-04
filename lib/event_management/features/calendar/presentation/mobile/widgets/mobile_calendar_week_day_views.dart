import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../domain/entities/calendar_grid_event.dart';
import '../../../domain/entities/calendar_holiday.dart';
import '../../../shared/calendar_date_utils.dart';
import '../mobile_calendar_theme.dart';
import 'mobile_calendar_week_grid.dart';

class MobileCalendarWeekView extends StatelessWidget {
  const MobileCalendarWeekView({
    super.key,
    required this.anchor,
    required this.selectedDate,
    required this.events,
    required this.holidaysByDate,
    required this.onDayTap,
    required this.onSlotTap,
    required this.onEventTap,
    required this.onEventMove,
  });

  final DateTime anchor;
  final DateTime selectedDate;
  final List<CalendarGridEvent> events;
  final Map<String, List<CalendarHoliday>> holidaysByDate;
  final ValueChanged<DateTime> onDayTap;
  final void Function(DateTime start, DateTime end) onSlotTap;
  final ValueChanged<CalendarGridEvent> onEventTap;
  final void Function(CalendarGridEvent event, DateTime newStart, DateTime newEnd)
      onEventMove;

  static const _dowLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  List<DateTime> _weekDays() {
    final first = DateTime(anchor.year, anchor.month, anchor.day);
    final start = first.subtract(Duration(days: first.weekday % 7));
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    final days = _weekDays();
    final today = CalendarDateUtils.dateOnly(DateTime.now());

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 12, 10),
          child: Row(
            children: List.generate(7, (index) {
              final d = days[index];
              final selected = CalendarDateUtils.isSameDay(d, selectedDate);
              final isToday = CalendarDateUtils.isSameDay(d, today);
              final inAnchorMonth =
                  d.month == anchor.month && d.year == anchor.year;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onDayTap(d),
                  child: Column(
                    children: [
                      Text(
                        _dowLabels[index],
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: MobileCalendarTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 36,
                        height: 36,
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
                          '${d.day}',
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: selected
                                ? Colors.white
                                : inAnchorMonth
                                    ? MobileCalendarTheme.textDark
                                    : MobileCalendarTheme.textMuted
                                        .withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        const Divider(
          height: 1,
          thickness: 1,
          color: MobileCalendarTheme.border,
          indent: 8,
          endIndent: 12,
        ),
        Expanded(
          child: MobileCalendarWeekGrid(
            days: days,
            events: events,
            holidaysByDate: holidaysByDate,
            onSlotTap: onSlotTap,
            onEventTap: onEventTap,
            onEventMove: onEventMove,
          ),
        ),
      ],
    );
  }
}
