import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/analytics_theme.dart';
import '../../utils/iso_week.dart';

class IsoWeekPicker extends StatelessWidget {
  final int year;
  final int week;
  final void Function(int year, int week) onChanged;
  final bool mobile;

  const IsoWeekPicker({
    super.key,
    required this.year,
    required this.week,
    required this.onChanged,
    this.mobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final maxWeek = IsoWeek.weeksInYear(year);
    final weeks = List.generate(maxWeek, (i) => i + 1);
    final years = List.generate(5, (i) => DateTime.now().year - 2 + i);

    return Container(
      margin: mobile ? const EdgeInsets.symmetric(horizontal: 16, vertical: 4) : null,
      padding: EdgeInsets.fromLTRB(mobile ? 14 : 24, mobile ? 8 : 0, mobile ? 14 : 24, 12),
      decoration: BoxDecoration(
        color: mobile ? AnalyticsMobileTheme.card : AnalyticsDesktopTheme.surface,
        borderRadius: mobile ? BorderRadius.circular(14) : null,
      ),
      child: Row(
        children: [
          Text(
            'ISO Week',
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w800,
              color: mobile
                  ? AnalyticsMobileTheme.textMuted
                  : AnalyticsDesktopTheme.textMuted,
            ),
          ),
          const SizedBox(width: 12),
          DropdownButton<int>(
            value: year,
            items: years
                .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                .toList(),
            onChanged: (y) {
              if (y == null) return;
              final w = week.clamp(1, IsoWeek.weeksInYear(y));
              onChanged(y, w);
            },
          ),
          const SizedBox(width: 8),
          DropdownButton<int>(
            value: week.clamp(1, maxWeek),
            items: weeks
                .map((w) => DropdownMenuItem(value: w, child: Text('W$w')))
                .toList(),
            onChanged: (w) {
              if (w != null) onChanged(year, w);
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              IsoWeek.rangeLabel(year, week),
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: mobile
                    ? AnalyticsMobileTheme.textMuted
                    : AnalyticsDesktopTheme.labelMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
