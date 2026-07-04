import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/calendar_grid_event.dart';
import '../../../domain/entities/calendar_holiday.dart';
import '../../../shared/calendar_date_utils.dart';
import '../mobile_calendar_theme.dart';
import 'mobile_event_card.dart';

class MobileCalendarScheduleView extends StatelessWidget {
  const MobileCalendarScheduleView({
    super.key,
    required this.events,
    required this.holidaysByDate,
    required this.onEventTap,
  });

  final List<CalendarGridEvent> events;
  final Map<String, List<CalendarHoliday>> holidaysByDate;
  final ValueChanged<CalendarGridEvent> onEventTap;

  @override
  Widget build(BuildContext context) {
    final grouped = <DateTime, List<CalendarGridEvent>>{};
    for (final e in events) {
      final d = CalendarDateUtils.dateOnly(e.startTime.toLocal());
      grouped.putIfAbsent(d, () => []).add(e);
    }

    final dates = grouped.keys.toList()..sort();
    if (dates.isEmpty) {
      return Center(
        child: Text(
          'No upcoming events',
          style: GoogleFonts.manrope(
            color: MobileCalendarTheme.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    final today = CalendarDateUtils.dateOnly(DateTime.now());

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
      itemCount: dates.length,
      itemBuilder: (context, index) {
        final day = dates[index];
        final items = grouped[day]!
          ..sort((a, b) => a.startTime.compareTo(b.startTime));
        final isToday = CalendarDateUtils.isSameDay(day, today);
        final dow = DateFormat('EEE').format(day).toUpperCase();
        final mon = DateFormat('MMM').format(day);

        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 52,
                child: Column(
                  children: [
                    Text(
                      dow,
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: MobileCalendarTheme.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isToday
                            ? MobileCalendarTheme.terracotta
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${day.day}',
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: isToday
                                  ? Colors.white
                                  : MobileCalendarTheme.textDark,
                            ),
                          ),
                          Text(
                            mon,
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w700,
                              fontSize: 9,
                              color: isToday
                                  ? Colors.white.withValues(alpha: 0.9)
                                  : MobileCalendarTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  children: items
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: MobileEventCard(
                            event: e,
                            onTap: () => onEventTap(e),
                            showJoin: true,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
