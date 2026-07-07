import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:my_app/employee_dashboard/bloc/employee_dashboard_bloc.dart';
import 'package:my_app/employee_dashboard/bloc/employee_dashboard_state.dart';
import 'package:my_app/employee_dashboard/model/weekly_activity_model.dart';

import 'employee_dashboard_v2_theme.dart';

/// Weekly hours chart driven by punch-in / break data from the backend.
class EmployeeDashboardV2WeeklyActivity extends StatelessWidget {
  const EmployeeDashboardV2WeeklyActivity({super.key});

  /// Space for the day letter + gap below the bar stack.
  static const _dayFooterHeight = 28.0;
  /// Space for the hour label + gap above the bars.
  static const _hourLabelHeight = 28.0;

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
        final maxStack = days.fold<double>(
          0,
          (max, d) {
            final stack = d.workedHours + d.breakHours;
            return stack > max ? stack : max;
          },
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weekly Activity',
                        style: EmployeeDashboardV2Theme.sectionTitle(),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${DateFormat('MMM d').format(days.first.date)} – ${DateFormat('MMM d').format(days.last.date)} · hours per day',
                        style: EmployeeDashboardV2Theme.sectionSubtitle(),
                      ),
                    ],
                  ),
                ),
                _legend(const Color(0xFF059669), 'Worked'),
                const SizedBox(width: 16),
                _legend(EmployeeDashboardV2Theme.amber, 'Break'),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final labelOverhead = _dayFooterHeight + _hourLabelHeight;
                  final maxBarPx =
                      (constraints.maxHeight - labelOverhead).clamp(40.0, 280.0);
                  final scale = maxStack > 0 ? maxBarPx / maxStack : 0.0;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final day in days) ...[
                        Expanded(child: _dayBar(day, scale)),
                        if (day != days.last) const SizedBox(width: 14),
                      ],
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.only(top: 18),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: EmployeeDashboardV2Theme.rowBorder)),
              ),
              child: Row(
                children: [
                  _summaryItem('Total worked', formatWeeklyHours(weekly.totalWorked)),
                  const SizedBox(width: 28),
                  _summaryItem('Total break', formatWeeklyHours(weekly.totalBreak)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _summaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFA7BFB2),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
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
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 7),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: EmployeeDashboardV2Theme.textBody,
          ),
        ),
      ],
    );
  }

  Widget _dayBar(WeeklyActivityDay day, double scale) {
    final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final dayKey = DateFormat('yyyy-MM-dd').format(day.date);
    final isToday = dayKey == todayKey;
    final hasData = day.netWork.inSeconds > 0 || day.totalBreak.inSeconds > 0;

    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableForBars =
                  (constraints.maxHeight - _hourLabelHeight).clamp(0.0, double.infinity);
              final rawWorkH = day.workedHours * scale;
              final rawBreakH = day.breakHours * scale;
              final totalRaw = rawWorkH + rawBreakH;
              final fitScale = totalRaw > availableForBars && totalRaw > 0
                  ? availableForBars / totalRaw
                  : 1.0;
              final workH = rawWorkH * fitScale;
              final breakH = rawBreakH * fitScale;

              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    formatWeeklyHours(day.netWork),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: EmployeeDashboardV2Theme.textDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (breakH > 0)
                    Container(
                      width: 40,
                      height: breakH,
                      decoration: const BoxDecoration(
                        color: EmployeeDashboardV2Theme.amber,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                      ),
                    ),
                  Container(
                    width: 40,
                    height: workH > 0 ? workH : (hasData ? 4 : 0),
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
                          : (hasData ? EmployeeDashboardV2Theme.rowBorder : Colors.transparent),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(breakH > 0 ? 0 : 6),
                        bottom: const Radius.circular(6),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Text(
          DateFormat('E').format(day.date).substring(0, 1),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isToday
                ? EmployeeDashboardV2Theme.greenDark
                : EmployeeDashboardV2Theme.textMuted,
          ),
        ),
      ],
    );
  }
}
