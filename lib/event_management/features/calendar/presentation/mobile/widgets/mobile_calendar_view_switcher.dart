import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../bloc/calender_event.dart';
import '../mobile_calendar_theme.dart';

class MobileCalendarViewSwitcher extends StatelessWidget {
  const MobileCalendarViewSwitcher({
    super.key,
    required this.view,
    required this.onChanged,
  });

  final CalendarView view;
  final ValueChanged<CalendarView> onChanged;

  static const _labels = {
    CalendarView.month: 'Month',
    CalendarView.week: 'Week',
    CalendarView.day: 'Day',
    CalendarView.agenda: 'Schedule',
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: MobileCalendarTheme.segmentBg,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: CalendarView.values.map((v) {
            final selected = view == v;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(v),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? MobileCalendarTheme.card : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _labels[v]!,
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: selected
                          ? MobileCalendarTheme.textDark
                          : MobileCalendarTheme.textMuted,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
