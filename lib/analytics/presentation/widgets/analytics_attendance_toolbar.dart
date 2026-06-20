import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../bloc/analytics_bloc.dart';
import '../../bloc/analytics_event.dart';
import '../../bloc/analytics_state.dart';
import '../../theme/analytics_theme.dart';
import '../../utils/analytics_date_utils.dart';
import '../../utils/iso_week.dart';
import 'attendance_day_filter.dart';
import 'package:my_app/core/widgets/analytics_icons.dart';

/// Attendance filters: week navigation, daily/weekly toggle, day picker.
class AnalyticsAttendanceToolbar extends StatelessWidget {
  final AnalyticsState state;

  const AnalyticsAttendanceToolbar({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final years = List.generate(5, (i) => DateTime.now().year - 2 + i);
    final maxWeek = IsoWeek.weeksInYear(state.year);
    final weeks = List.generate(maxWeek, (i) => i + 1);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _NavBtn(
                icon: AnalyticsIconType.chevronLeft,
                onTap: () => _shiftWeek(context, -1),
              ),
              const SizedBox(width: 8),
              _Dropdown<int>(
                value: state.year,
                items: years.map((y) => (y, '$y')).toList(),
                onChanged: (y) => _setWeek(context, y, state.week),
              ),
              const SizedBox(width: 8),
              _Dropdown<int>(
                value: state.week.clamp(1, maxWeek),
                items: weeks.map((w) => (w, 'Week $w')).toList(),
                onChanged: (w) => _setWeek(context, state.year, w),
              ),
              const SizedBox(width: 8),
              _NavBtn(
                icon: AnalyticsIconType.chevronRight,
                onTap: () => _shiftWeek(context, 1),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  IsoWeek.weekPickerLabel(state.year, state.week),
                  style: AnalyticsDesktopTheme.bodySm,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SubviewToggle(subview: state.attendanceSubview),
          if (state.attendanceSubview == WeeklyAttendanceSubview.daily) ...[
            const SizedBox(height: 12),
            AttendanceDayFilter(
              year: state.year,
              week: state.week,
              embedded: true,
              selectedDayKey: state.attendanceDayFilter ??
                  AnalyticsDateUtils.defaultDayKeyForIsoWeek(
                    state.year,
                    state.week,
                  ),
              onChanged: (key) => context.read<AnalyticsBloc>().add(
                    AnalyticsAttendanceDayFilterChanged(key),
                  ),
            ),
          ],
          const SizedBox(height: 16),
          const Divider(height: 1, color: AnalyticsDesktopTheme.border),
        ],
      ),
    );
  }

  void _setWeek(BuildContext context, int year, int week) {
    context.read<AnalyticsBloc>().add(
          AnalyticsWeekChanged(
            year: year,
            week: week.clamp(1, IsoWeek.weeksInYear(year)),
          ),
        );
  }

  void _shiftWeek(BuildContext context, int delta) {
    var week = state.week + delta;
    var year = state.year;
    if (week < 1) {
      year -= 1;
      week = IsoWeek.weeksInYear(year);
    } else if (week > IsoWeek.weeksInYear(year)) {
      year += 1;
      week = 1;
    }
    context.read<AnalyticsBloc>().add(
          AnalyticsWeekChanged(year: year, week: week),
        );
  }
}

class _NavBtn extends StatelessWidget {
  final AnalyticsIconType icon;
  final VoidCallback onTap;

  const _NavBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AnalyticsDesktopTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AnalyticsDesktopTheme.controlRadius),
        side: const BorderSide(color: AnalyticsDesktopTheme.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AnalyticsDesktopTheme.controlRadius),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Center(
            child: AnalyticsIcon(
              type: icon,
              size: 22,
              color: AnalyticsDesktopTheme.textMain,
            ),
          ),
        ),
      ),
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  final T value;
  final List<(T, String)> items;
  final ValueChanged<T> onChanged;

  const _Dropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AnalyticsDesktopTheme.border),
        borderRadius: BorderRadius.circular(AnalyticsDesktopTheme.controlRadius),
        color: AnalyticsDesktopTheme.surface,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          style: AnalyticsDesktopTheme.tableCellBold,
          items: items
              .map(
                (e) => DropdownMenuItem<T>(value: e.$1, child: Text(e.$2)),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

class _SubviewToggle extends StatelessWidget {
  final WeeklyAttendanceSubview subview;

  const _SubviewToggle({required this.subview});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AnalyticsDesktopTheme.tableHeader,
        borderRadius: BorderRadius.circular(AnalyticsDesktopTheme.controlRadius),
        border: Border.all(color: AnalyticsDesktopTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Tab(
            label: 'Daily',
            icon: AnalyticsIconType.check,
            selected: subview == WeeklyAttendanceSubview.daily,
            onTap: () => context.read<AnalyticsBloc>().add(
                  const AnalyticsAttendanceSubviewChanged(
                    WeeklyAttendanceSubview.daily,
                  ),
                ),
          ),
          _Tab(
            label: 'Weekly summary',
            selected: subview == WeeklyAttendanceSubview.weeklySummary,
            onTap: () => context.read<AnalyticsBloc>().add(
                  const AnalyticsAttendanceSubviewChanged(
                    WeeklyAttendanceSubview.weeklySummary,
                  ),
                ),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final AnalyticsIconType? icon;
  final bool selected;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AnalyticsDesktopTheme.purple : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected && icon != null) ...[
                AnalyticsIcon(type: icon!, size: 16, color: Colors.white),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? Colors.white
                      : AnalyticsDesktopTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
