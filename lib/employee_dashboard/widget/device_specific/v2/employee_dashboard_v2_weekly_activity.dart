import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:my_app/employee_dashboard/bloc/employee_dashboard_bloc.dart';
import 'package:my_app/employee_dashboard/bloc/employee_dashboard_state.dart';
import 'package:my_app/employee_dashboard/model/weekly_activity_model.dart';

import 'employee_dashboard_v2_theme.dart';

/// Weekly hours chart driven by punch-in / break data from the backend.
class EmployeeDashboardV2WeeklyActivity extends StatefulWidget {
  const EmployeeDashboardV2WeeklyActivity({super.key});

  @override
  State<EmployeeDashboardV2WeeklyActivity> createState() =>
      _EmployeeDashboardV2WeeklyActivityState();
}

class _EmployeeDashboardV2WeeklyActivityState
    extends State<EmployeeDashboardV2WeeklyActivity> {
  static const _dayLabelHeight = 18.0;
  static const _dayLabelGap = 8.0;
  static const _hourLabelHeight = 18.0;
  static const _hourLabelGap = 8.0;
  static const _dayFooterHeight = _dayLabelGap + _dayLabelHeight;

  int? _hoveredDayIndex;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmployeeBloc, EmployeeState>(
      buildWhen: (prev, curr) =>
          prev.weeklyActivity != curr.weeklyActivity ||
          prev.attendance?.netWork != curr.attendance?.netWork ||
          prev.attendance?.totalBreak != curr.attendance?.totalBreak,
      builder: (context, state) {
        final weekly =
            state.weeklyActivity ?? WeeklyActivityModel.forCalendarWeek();
        final days = weekly.days;
        final maxStack = math.max(
          days.fold<double>(
            0,
            (max, d) {
              final stack = d.workedHours + d.breakHours;
              return stack > max ? stack : max;
            },
          ),
          0.25,
        );

        return LayoutBuilder(
          builder: (context, constraints) {
            const headerHeight = 48.0;
            const footerHeight = 58.0;
            const verticalGaps = 12.0;
            final chartHeight = (constraints.maxHeight -
                    headerHeight -
                    footerHeight -
                    verticalGaps)
                .clamp(96.0, double.infinity);
            final barStackHeight = (chartHeight - _dayFooterHeight).clamp(
              48.0,
              double.infinity,
            );
            final maxBarPx = (barStackHeight -
                    _hourLabelHeight -
                    _hourLabelGap)
                .clamp(24.0, 220.0);
            final scale = maxStack > 0 ? maxBarPx / maxStack : 0.0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: headerHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Weekly Activity',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: EmployeeDashboardV2Theme.sectionTitle(),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${DateFormat('MMM d').format(days.first.date)} – ${DateFormat('MMM d').format(days.last.date)} · hours per day',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: EmployeeDashboardV2Theme.sectionSubtitle(),
                            ),
                          ],
                        ),
                      ),
                      _legend(const Color(0xFF059669), 'Worked'),
                      const SizedBox(width: 12),
                      _legend(EmployeeDashboardV2Theme.amber, 'Break'),
                    ],
                  ),
                ),
                const SizedBox(height: verticalGaps),
                SizedBox(
                  height: chartHeight,
                  child: Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          for (var i = 0; i < days.length; i++) ...[
                            Expanded(
                              child: _dayBar(
                                height: chartHeight,
                                day: days[i],
                                scale: scale,
                                isHovered: _hoveredDayIndex == i,
                                onHover: (hovered) {
                                  setState(() {
                                    _hoveredDayIndex = hovered ? i : null;
                                  });
                                },
                              ),
                            ),
                            if (i < days.length - 1) const SizedBox(width: 10),
                          ],
                        ],
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: IgnorePointer(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            child: _hoveredDayIndex != null
                                ? _BarHoverTooltip(
                                    key: ValueKey(_hoveredDayIndex),
                                    day: days[_hoveredDayIndex!],
                                    weekly: weekly,
                                  )
                                : const SizedBox.shrink(key: ValueKey('empty')),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: footerHeight,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(top: 10),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: EmployeeDashboardV2Theme.rowBorder),
                      ),
                    ),
                    child: Row(
                      children: [
                        _summaryItem(
                          'Total worked',
                          formatWeeklyHours(weekly.totalWorked),
                          highlighted: _hoveredDayIndex != null,
                        ),
                        const SizedBox(width: 24),
                        _summaryItem(
                          'Total break',
                          formatWeeklyHours(weekly.totalBreak),
                          highlighted: _hoveredDayIndex != null,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _summaryItem(String label, String value, {bool highlighted = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: highlighted
                ? EmployeeDashboardV2Theme.greenMid
                : const Color(0xFFA7BFB2),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: EmployeeDashboardV2Theme.textDark,
          ),
        ),
      ],
    );
  }

  Widget _legend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: EmployeeDashboardV2Theme.textBody,
          ),
        ),
      ],
    );
  }

  Widget _dayBar({
    required double height,
    required WeeklyActivityDay day,
    required double scale,
    required bool isHovered,
    required ValueChanged<bool> onHover,
  }) {
    final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final dayKey = DateFormat('yyyy-MM-dd').format(day.date);
    final isToday = dayKey == todayKey;
    final hasData = day.netWork.inSeconds > 0 || day.totalBreak.inSeconds > 0;
    final stackHeight = (height - _dayFooterHeight).clamp(0.0, double.infinity);
    final availableForBars =
        (stackHeight - _hourLabelHeight - _hourLabelGap).clamp(0.0, double.infinity);
    final rawWorkH = day.workedHours * scale;
    final rawBreakH = day.breakHours * scale;
    final totalRaw = rawWorkH + rawBreakH;
    final fitScale =
        totalRaw > availableForBars && totalRaw > 0 ? availableForBars / totalRaw : 1.0;
    var workH = rawWorkH * fitScale;
    var breakH = rawBreakH * fitScale;
    if (day.netWork.inSeconds > 0 && workH < 4) workH = 4;
    if (day.totalBreak.inSeconds > 0 && breakH < 3) breakH = 3;

    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onHover(!isHovered),
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: height,
          child: Column(
            children: [
              SizedBox(
                height: stackHeight,
                child: ClipRect(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: _hourLabelHeight,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Text(
                            formatWeeklyHours(day.netWork),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isHovered
                                  ? EmployeeDashboardV2Theme.greenDark
                                  : EmployeeDashboardV2Theme.textDark,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: _hourLabelGap),
                      Transform.scale(
                        scale: isHovered ? 1.03 : 1,
                        alignment: Alignment.bottomCenter,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (breakH > 0)
                              Container(
                                width: 36,
                                height: breakH,
                                decoration: BoxDecoration(
                                  color: EmployeeDashboardV2Theme.amber,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(5),
                                  ),
                                ),
                              ),
                            Container(
                              width: 36,
                              height: workH > 0 ? workH : (hasData ? 3 : 0),
                              decoration: BoxDecoration(
                                gradient: isToday && workH > 0
                                    ? const LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          EmployeeDashboardV2Theme.green,
                                          Color(0xFF059669),
                                        ],
                                      )
                                    : (workH > 0
                                        ? const LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              EmployeeDashboardV2Theme.greenChip,
                                              EmployeeDashboardV2Theme.green,
                                            ],
                                          )
                                        : null),
                                color: workH > 0
                                    ? null
                                    : (hasData
                                        ? EmployeeDashboardV2Theme.rowBorder
                                        : Colors.transparent),
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(breakH > 0 ? 0 : 5),
                                  bottom: const Radius.circular(5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: _dayLabelGap),
              SizedBox(
                height: _dayLabelHeight,
                child: Center(
                  child: Text(
                    DateFormat('E').format(day.date).substring(0, 1),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isHovered || isToday
                          ? EmployeeDashboardV2Theme.greenDark
                          : EmployeeDashboardV2Theme.textMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarHoverTooltip extends StatelessWidget {
  const _BarHoverTooltip({
    super.key,
    required this.day,
    required this.weekly,
  });

  final WeeklyActivityDay day;
  final WeeklyActivityModel weekly;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: EmployeeDashboardV2Theme.cardMuted.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: EmployeeDashboardV2Theme.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('EEEE, MMM d').format(day.date),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: EmployeeDashboardV2Theme.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                _tooltipRow(
                  color: const Color(0xFF059669),
                  label: 'Working time',
                  value: formatWeeklyHours(day.netWork),
                ),
                const SizedBox(height: 3),
                _tooltipRow(
                  color: EmployeeDashboardV2Theme.amber,
                  label: 'Break time',
                  value: formatWeeklyHours(day.totalBreak),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 44,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: EmployeeDashboardV2Theme.rowBorder,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'This week',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: EmployeeDashboardV2Theme.textMuted,
                ),
              ),
              const SizedBox(height: 6),
              _tooltipRow(
                color: const Color(0xFF059669),
                label: 'Total worked',
                value: formatWeeklyHours(weekly.totalWorked),
              ),
              const SizedBox(height: 3),
              _tooltipRow(
                color: EmployeeDashboardV2Theme.amber,
                label: 'Total break',
                value: formatWeeklyHours(weekly.totalBreak),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tooltipRow({
    required Color color,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: EmployeeDashboardV2Theme.textBody,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: EmployeeDashboardV2Theme.textDark,
          ),
        ),
      ],
    );
  }
}
