import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:my_app/event_management/features/calendar/domain/entities/calendar_holiday.dart';
import 'package:my_app/event_management/features/calendar/presentation/widget/holiday_popover.dart';
import 'package:my_app/event_management/features/calendar/shared/holiday_ui_theme.dart';
import '../../shared/dashboard_ui_theme.dart';

/// Month holidays — flat on page surface (no white card).
class DashboardHolidaySection extends StatelessWidget {
  const DashboardHolidaySection({
    super.key,
    required this.holidays,
  });

  final List<CalendarHoliday> holidays;

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat('MMMM yyyy').format(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 22,
              decoration: BoxDecoration(
                color: HolidayUiTheme.orange,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Holidays',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: DashboardUiTheme.textDark,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: HolidayUiTheme.bg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                monthLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: HolidayUiTheme.text,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        if (holidays.isEmpty)
          Text(
            'No public holidays this month.',
            style: TextStyle(
              color: DashboardUiTheme.textMuted.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          )
        else
          for (var i = 0; i < holidays.length; i++)
            _HolidaySurfaceRow(
              holiday: holidays[i],
              showDivider: i < holidays.length - 1,
            ),
      ],
    );
  }
}

class _HolidaySurfaceRow extends StatelessWidget {
  const _HolidaySurfaceRow({
    required this.holiday,
    this.showDivider = true,
  });

  final CalendarHoliday holiday;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final dt = holiday.dateTime ?? DateTime.now();
    final dateLabel = DateFormat('EEE, MMM d').format(dt);
    final local = holiday.localName.trim();

    return Column(
      children: [
        InkWell(
          onTap: () => showHolidayPopover(context, holiday: holiday),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 72,
                  child: Text(
                    dateLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: DashboardUiTheme.textMuted,
                      height: 1.3,
                    ),
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: HolidayUiTheme.bg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      HolidayUiTheme.flag,
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        holiday.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: HolidayUiTheme.text,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (local.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          local,
                          style: TextStyle(
                            fontSize: 12,
                            color: HolidayUiTheme.text.withValues(alpha: 0.75),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: HolidayUiTheme.orange.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: DashboardUiTheme.border.withValues(alpha: 0.55),
          ),
      ],
    );
  }
}
