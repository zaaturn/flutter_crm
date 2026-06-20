import 'package:flutter/material.dart';

import '../../theme/analytics_theme.dart';
import '../../utils/iso_week.dart';

class WeekPickerBar extends StatelessWidget {
  final int year;
  final int week;
  final ValueChanged<int> onYearChanged;
  final ValueChanged<int> onWeekChanged;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool mobile;
  final bool embedded;

  const WeekPickerBar({
    super.key,
    required this.year,
    required this.week,
    required this.onYearChanged,
    required this.onWeekChanged,
    required this.onPrevious,
    required this.onNext,
    this.mobile = false,
    this.embedded = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent =
        mobile ? AnalyticsMobileTheme.terracotta : AnalyticsDesktopTheme.purple;
    final years = List.generate(5, (i) => DateTime.now().year - 2 + i);
    final maxWeek = IsoWeek.weeksInYear(year);
    final weeks = List.generate(maxWeek, (i) => i + 1);

    return Container(
      margin: embedded
          ? null
          : (mobile
              ? const EdgeInsets.symmetric(horizontal: 16, vertical: 4)
              : null),
      padding: EdgeInsets.fromLTRB(
        embedded ? 20 : (mobile ? 10 : 24),
        embedded ? 20 : 8,
        embedded ? 20 : (mobile ? 10 : 24),
        embedded ? 16 : 8,
      ),
      color: embedded ? null : (mobile ? null : AnalyticsDesktopTheme.surface),
      decoration: embedded
          ? null
          : (mobile
              ? BoxDecoration(
                  color: AnalyticsMobileTheme.card,
                  borderRadius: BorderRadius.circular(14),
                )
              : null),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Previous week',
            onPressed: onPrevious,
            icon: Icon(Icons.chevron_left_rounded, color: accent),
          ),
          _chipDropdown(
            value: year,
            items: years.map((y) => (y, '$y')).toList(),
            onChanged: onYearChanged,
          ),
          const SizedBox(width: 8),
          _chipDropdown(
            value: week.clamp(1, maxWeek),
            items: weeks.map((w) => (w, 'Week $w')).toList(),
            onChanged: onWeekChanged,
          ),
          IconButton(
            tooltip: 'Next week',
            onPressed: onNext,
            icon: Icon(Icons.chevron_right_rounded, color: accent),
          ),
          Expanded(
            child: Text(
              IsoWeek.weekPickerLabel(year, week),
              style: AnalyticsDesktopTheme.bodySm,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipDropdown<T>({
    required T value,
    required List<(T, String)> items,
    required ValueChanged<T> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: AnalyticsDesktopTheme.border),
        borderRadius: BorderRadius.circular(AnalyticsDesktopTheme.controlRadius),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          style: AnalyticsDesktopTheme.tableCellBold,
          items: items
              .map((e) => DropdownMenuItem<T>(value: e.$1, child: Text(e.$2)))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}
