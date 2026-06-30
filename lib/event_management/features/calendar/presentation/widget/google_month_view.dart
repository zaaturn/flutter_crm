import 'package:flutter/material.dart';

import '../../domain/entities/calendar_grid_event.dart';
import '../../domain/entities/calendar_holiday.dart';
import '../../shared/calendar_date_utils.dart';
import '../../shared/calendar_ui_theme.dart';
import '../../shared/holiday_ui_theme.dart';
import 'calendar_event_chip.dart';
import 'holiday_chip.dart';

class GoogleMonthView extends StatelessWidget {
  const GoogleMonthView({
    super.key,
    required this.focusedMonth,
    required this.selectedDate,
    required this.events,
    required this.dotMap,
    required this.holidaysByDate,
    required this.onDayTap,
    required this.onEventTap,
  });

  final DateTime focusedMonth;
  final DateTime selectedDate;
  final List<CalendarGridEvent> events;
  final Map<String, List<String>> dotMap;
  final Map<String, List<CalendarHoliday>> holidaysByDate;
  final ValueChanged<DateTime> onDayTap;
  final ValueChanged<CalendarGridEvent> onEventTap;

  List<CalendarGridEvent> _forDay(DateTime day) {
    return events.where((e) {
      final s = e.startTime.toLocal();
      final d = DateTime(s.year, s.month, s.day);
      return CalendarDateUtils.isSameDay(d, day);
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  Color _dotColor(String type) {
    if (type == 'holiday') return HolidayUiTheme.orange;
    return CalendarUiTheme.legendColor(type);
  }

  @override
  Widget build(BuildContext context) {
    final days = CalendarDateUtils.daysInMonthGrid(focusedMonth);
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 24, 20),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CalendarUiTheme.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            children: [
              Container(
                height: 44,
                decoration: const BoxDecoration(
                  color: CalendarUiTheme.surface,
                  border: Border(
                    bottom: BorderSide(color: CalendarUiTheme.border),
                  ),
                ),
                child: Row(
                  children: weekdays
                      .map(
                        (w) => Expanded(
                          child: Center(
                            child: Text(
                              w.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: CalendarUiTheme.textMuted,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const rowCount = 6;
                    final rowHeight = constraints.maxHeight / rowCount;
                    return GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisExtent: rowHeight,
                      ),
                      itemCount: days.length,
                      itemBuilder: (context, index) {
                        return _buildDayCell(
                          day: days[index],
                          rowHeight: rowHeight,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayCell({required DateTime day, required double rowHeight}) {
    final inMonth = day.month == focusedMonth.month;
    final isSelected = CalendarDateUtils.isSameDay(day, selectedDate);
    final isSunday = day.weekday == DateTime.sunday;
    final key = CalendarDateUtils.dateKey(day);
    final dayHolidays = holidaysByDate[key] ?? const [];
    final hasHoliday = dayHolidays.isNotEmpty;
    final dayEvents = _forDay(day);
    final dots = dotMap[key] ?? const [];

    Color cellBg = inMonth ? Colors.white : const Color(0xFFFAFAFA);
    if (hasHoliday) {
      cellBg = HolidayUiTheme.dayTint;
    } else if (isSunday && inMonth) {
      cellBg = HolidayUiTheme.sundayTint;
    }

    Color dayNumColor = inMonth
        ? CalendarUiTheme.textDark
        : const Color(0xFF9CA3AF);
    if (hasHoliday && !isSelected) {
      dayNumColor = HolidayUiTheme.orange;
    }

    return GestureDetector(
      onTap: () => onDayTap(day),
      child: Container(
        height: rowHeight,
        decoration: BoxDecoration(
          color: cellBg,
          border: Border.all(
            color: CalendarUiTheme.border,
            width: 0.5,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected ? CalendarUiTheme.primary : null,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    height: 1,
                    color: isSelected
                        ? Colors.white
                        : dayNumColor,
                  ),
                ),
              ),
            ),
            if (hasHoliday)
              HolidayMonthChip(
                holiday: dayHolidays.first,
                compact: true,
              ),
            Expanded(
              child: ClipRect(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: dayEvents.take(2).map(
                    (e) => CalendarEventChip(
                      event: e,
                      compact: true,
                      onTap: () => onEventTap(e),
                    ),
                  ).toList(),
                ),
              ),
            ),
            if (dots.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: dots.take(4).map((type) {
                  return Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: _dotColor(type),
                      shape: BoxShape.circle,
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
