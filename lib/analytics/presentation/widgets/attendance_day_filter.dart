import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/analytics_theme.dart';
import '../../utils/analytics_date_utils.dart';

/// Day dropdown for daily attendance — one day at a time.
class AttendanceDayFilter extends StatelessWidget {
  final int year;
  final int week;
  final String selectedDayKey;
  final ValueChanged<String> onChanged;
  final bool mobile;
  final bool embedded;

  const AttendanceDayFilter({
    super.key,
    required this.year,
    required this.week,
    required this.selectedDayKey,
    required this.onChanged,
    this.mobile = false,
    this.embedded = false,
  });

  @override
  Widget build(BuildContext context) {
    final options = AnalyticsDateUtils.isoWeekDayOptions(year, week);
    final value = options.any((o) => o.key == selectedDayKey)
        ? selectedDayKey
        : options.first.key;

    if (embedded) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: AnalyticsDesktopTheme.border),
          borderRadius: BorderRadius.circular(AnalyticsDesktopTheme.controlRadius),
          color: AnalyticsDesktopTheme.surface,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: AnalyticsDesktopTheme.textMuted,
            ),
            const SizedBox(width: 10),
            Text('Select day', style: AnalyticsDesktopTheme.bodySm),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: value,
                  style: AnalyticsDesktopTheme.tableCellBold.copyWith(
                    color: AnalyticsDesktopTheme.purple,
                  ),
                  items: options
                      .map(
                        (o) => DropdownMenuItem(
                          value: o.key,
                          child: Text(o.label),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) onChanged(v);
                  },
                ),
              ),
            ),
          ],
        ),
      );
    }

    final accent =
        mobile ? AnalyticsMobileTheme.terracotta : AnalyticsDesktopTheme.purple;

    return Container(
      margin: mobile
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 4)
          : const EdgeInsets.fromLTRB(24, 0, 24, 8),
      padding: EdgeInsets.symmetric(
        horizontal: mobile ? 14 : 16,
        vertical: mobile ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: mobile ? AnalyticsMobileTheme.card : AnalyticsDesktopTheme.purpleLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_view_day_rounded, color: accent, size: 22),
          const SizedBox(width: 12),
          Text(
            'Select day',
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: mobile
                  ? AnalyticsMobileTheme.textMuted
                  : AnalyticsDesktopTheme.textMuted,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: value,
                style: GoogleFonts.manrope(
                  color: accent,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
                items: options
                    .map(
                      (o) => DropdownMenuItem(
                        value: o.key,
                        child: Text(o.label),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) onChanged(v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
