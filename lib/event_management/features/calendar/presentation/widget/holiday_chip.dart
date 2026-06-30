import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/calendar_holiday.dart';
import '../../shared/holiday_ui_theme.dart';
import 'holiday_popover.dart';

class HolidayMonthChip extends StatelessWidget {
  const HolidayMonthChip({
    super.key,
    required this.holiday,
    this.compact = false,
    this.onTap,
  });

  final CalendarHoliday holiday;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => showHolidayPopover(context, holiday: holiday),
      child: Container(
        margin: EdgeInsets.only(bottom: compact ? 2 : 3),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 4 : 6,
          vertical: compact ? 2 : 3,
        ),
        decoration: HolidayUiTheme.chipDecoration,
        child: Text(
          '${HolidayUiTheme.flag} ${holiday.name}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: compact ? 9.5 : 10.5,
            fontWeight: FontWeight.w600,
            color: HolidayUiTheme.text,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}

class HolidayAllDayChip extends StatelessWidget {
  const HolidayAllDayChip({
    super.key,
    required this.holiday,
    this.onTap,
  });

  final CalendarHoliday holiday;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => showHolidayPopover(context, holiday: holiday),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          gradient: HolidayUiTheme.bannerGradient,
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(
          '${HolidayUiTheme.flag} ${holiday.name}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class HolidayAgendaRow extends StatelessWidget {
  const HolidayAgendaRow({super.key, required this.holiday});

  final CalendarHoliday holiday;

  @override
  Widget build(BuildContext context) {
    final dt = holiday.dateTime;
    final datePart =
        dt != null ? DateFormat('MMM d').format(dt) : holiday.date;

    return GestureDetector(
      onTap: () => showHolidayPopover(context, holiday: holiday),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: HolidayUiTheme.bg,
          borderRadius: BorderRadius.circular(10),
          border: const Border(
            left: BorderSide(color: HolidayUiTheme.orange, width: 4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${HolidayUiTheme.flag} ${holiday.name}',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: HolidayUiTheme.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'National Holiday — $datePart',
              style: TextStyle(
                fontSize: 12,
                color: HolidayUiTheme.text.withValues(alpha: 0.75),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
