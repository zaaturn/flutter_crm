import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:my_app/admin_dashboard/model/task.dart';
import 'package:my_app/admin_dashboard/shared/admin_dashboard_theme.dart';
import 'package:my_app/core/widgets/analytics_icons.dart';

import '../../../models/analytics_overview_model.dart';
import '../../../models/leave_analytics_model.dart';
import '../../../models/weekly_attendance_model.dart';
import '../../../theme/analytics_theme.dart';
import '../../../utils/analytics_date_utils.dart';
import '../../../utils/analytics_hours.dart';
import '../../../utils/iso_week.dart';
import '../analytics_compact_stat_card.dart';
import '../analytics_enterprise_table.dart';
import '../analytics_loading_widgets.dart';

/// Page size for overview roster panels (on leave, weekly summary table).
const _overviewPageSize = 10;

/// Fixed height for the weekly summary table inside the overview scroll view.
const _overviewSummaryTableHeight = 380.0;

class OverviewTab extends StatelessWidget {
  final AnalyticsOverviewModel? overview;
  final LeaveAnalyticsResponse? leaveAnalytics;
  final WeeklyAttendanceModel? weeklyAttendance;
  final List<Task>? overdueTasks;
  final bool tasksLoading;
  final Future<void> Function()? onRefresh;
  final bool mobile;

  const OverviewTab({
    super.key,
    this.overview,
    this.leaveAnalytics,
    this.weeklyAttendance,
    this.overdueTasks,
    this.tasksLoading = false,
    this.onRefresh,
    this.mobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final o = overview;
    if (o == null) {
      return const Center(child: Text('No overview data'));
    }

    final asOf = o.asOf != null
        ? DateFormat('dd MMM yyyy').format(
            DateTime.tryParse(o.asOf!) ?? DateTime.now(),
          )
        : null;

    final tiles = <({String label, String value, Color color})>[
      (
        label: 'Total employees',
        value: '${o.totalEmployees}',
        color: AnalyticsOverviewPalette.mutedTeal,
      ),
      (
        label: 'Checked in today',
        value: '${o.checkedInToday}',
        color: AnalyticsOverviewPalette.sageGreen,
      ),
      (
        label: 'On leave today',
        value: '${o.onLeaveToday}',
        color: AnalyticsOverviewPalette.softMauve,
      ),
      (
        label: 'Pending leaves',
        value: '${o.pendingLeaveRequests}',
        color: AnalyticsOverviewPalette.mustard,
      ),
      (
        label: 'Tasks pending',
        value: '${o.pendingTasks}',
        color: AnalyticsOverviewPalette.slateBlue,
      ),
      (
        label: 'Invoices this month',
        value: '${o.invoicesIssued}',
        color: AnalyticsOverviewPalette.warmBeige,
      ),
      (
        label: 'Amount received',
        value: o.formatReceived(),
        color: AnalyticsOverviewPalette.terracotta,
      ),
      (
        label: 'Payroll paid',
        value: o.formatPayrollPaid(),
        color: AnalyticsOverviewPalette.deepBrown,
      ),
    ];

    final gap = mobile ? 10.0 : AdminDashboardTheme.panelGap;

    final content = SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(
        mobile ? 14 : AdminDashboardTheme.shellPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (asOf != null)
            Padding(
              padding: EdgeInsets.only(left: mobile ? 0 : 4, bottom: 10),
              child: Text(
                'As of $asOf',
                style: AnalyticsDesktopTheme.bodySm.copyWith(
                  color: mobile
                      ? AnalyticsMobileTheme.textMuted
                      : AnalyticsDesktopTheme.textMuted,
                ),
              ),
            ),
          LayoutBuilder(
            builder: (context, c) {
              final cols = mobile ? 2 : (c.maxWidth > 900 ? 4 : 2);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: gap,
                  mainAxisSpacing: gap,
                  mainAxisExtent: mobile ? 86 : 100,
                ),
                itemCount: tiles.length,
                itemBuilder: (context, index) {
                  final tile = tiles[index];
                  if (mobile) {
                    return AnalyticsCompactStatCard(
                      label: tile.label,
                      value: tile.value,
                      background: tile.color,
                    );
                  }
                  return AdminDashboardPanel(
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: AnalyticsCompactStatCard(
                        label: tile.label,
                        value: tile.value,
                        background: tile.color,
                      ),
                    ),
                  );
                },
              );
            },
          ),
          if (!mobile) ...[
            SizedBox(height: gap + 6),
            _OverviewDetailSections(
              overview: o,
              leaveAnalytics: leaveAnalytics,
              weeklyAttendance: weeklyAttendance,
              overdueTasks: overdueTasks,
              tasksLoading: tasksLoading,
            ),
          ],
        ],
      ),
    );

    if (onRefresh == null) return content;
    return AnalyticsRefreshable(
      mobile: mobile,
      onRefresh: onRefresh!,
      child: content,
    );
  }
}

/// Desktop-only: attendance chart + on-leave-today / overdue-tasks panels,
/// side by side above ~800px and stacked below it.
class _OverviewDetailSections extends StatelessWidget {
  final AnalyticsOverviewModel overview;
  final LeaveAnalyticsResponse? leaveAnalytics;
  final WeeklyAttendanceModel? weeklyAttendance;
  final List<Task>? overdueTasks;
  final bool tasksLoading;

  const _OverviewDetailSections({
    required this.overview,
    required this.leaveAnalytics,
    required this.weeklyAttendance,
    required this.overdueTasks,
    required this.tasksLoading,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth > 800;
        const gap = AdminDashboardTheme.panelGap;
        final attendanceColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AttendanceWeekPanel(
              overview: overview,
              weeklyAttendance: weeklyAttendance,
            ),
            const SizedBox(height: gap),
            _WeeklySummaryPanel(weeklyAttendance: weeklyAttendance),
          ],
        );
        final sideColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _OnLeaveTodayPanel(leaveAnalytics: leaveAnalytics),
            const SizedBox(height: gap),
            _OverdueTasksPanel(tasks: overdueTasks, loading: tasksLoading),
          ],
        );

        if (!wide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [attendanceColumn, const SizedBox(height: gap), sideColumn],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: attendanceColumn),
            const SizedBox(width: gap),
            Expanded(child: sideColumn),
          ],
        );
      },
    );
  }
}

/// Separate dashboard panel for each Overview detail section.
class _Panel extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final int? badgeCount;
  final Widget child;

  const _Panel({
    required this.title,
    this.subtitle,
    this.trailing,
    this.badgeCount,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AdminDashboardPanel(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(title, style: AnalyticsDesktopTheme.titleMd),
                          if (badgeCount != null) ...[
                            const SizedBox(width: 8),
                            _CountBadge(count: badgeCount!),
                          ],
                        ],
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: AnalyticsDesktopTheme.bodySm
                              .copyWith(fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AnalyticsDesktopTheme.warningBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AnalyticsDesktopTheme.warning,
        ),
      ),
    );
  }
}

class _EmptyRow extends StatelessWidget {
  final AnalyticsIconType icon;
  final String message;
  const _EmptyRow({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          AnalyticsIcon(type: icon, size: 18, color: AnalyticsDesktopTheme.labelMuted),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: AnalyticsDesktopTheme.bodySm),
          ),
        ],
      ),
    );
  }
}

/// Mon–Sun bar chart. Today's bar uses the live `checkedInToday` count (that
/// day's weekly-attendance rows aren't final yet); past days are aggregated
/// from `weeklyAttendance.dailyRows`; future days render as empty bars.
class _AttendanceWeekPanel extends StatelessWidget {
  final AnalyticsOverviewModel overview;
  final WeeklyAttendanceModel? weeklyAttendance;

  const _AttendanceWeekPanel({required this.overview, this.weeklyAttendance});

  static const _weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  static bool _isPresent(WeeklyAttendanceDayRow r) {
    if (r.onLeave) return false;
    final s = r.status.toLowerCase();
    if (s.contains('absent') ||
        s.contains('leave') ||
        s.contains('holiday') ||
        s.contains('weekend')) {
      return false;
    }
    if ((r.checkIn ?? '').isNotEmpty) return true;
    if (r.netHours > 0 || r.cappedHours > 0) return true;
    return s.contains('present') || s.contains('work') || s.contains('check');
  }

  @override
  Widget build(BuildContext context) {
    final rows = weeklyAttendance?.dailyRows ?? const <WeeklyAttendanceDayRow>[];
    final byWeekday = <int, List<WeeklyAttendanceDayRow>>{};
    for (final r in rows) {
      final d = r.date;
      if (d == null) continue;
      byWeekday.putIfAbsent(d.weekday, () => []).add(r);
    }

    final todayWeekday = DateTime.now().weekday;
    final values = <int, int>{};
    final hasData = <int, bool>{};
    for (var wd = 1; wd <= 7; wd++) {
      if (wd == todayWeekday) {
        values[wd] = overview.checkedInToday;
        hasData[wd] = true;
      } else if (wd < todayWeekday) {
        final dayRows = byWeekday[wd] ?? const <WeeklyAttendanceDayRow>[];
        values[wd] = dayRows.where(_isPresent).length;
        hasData[wd] = dayRows.isNotEmpty;
      } else {
        values[wd] = 0;
        hasData[wd] = false;
      }
    }

    final maxValue = [
      if (overview.totalEmployees > 0) overview.totalEmployees,
      ...values.values,
      1,
    ].reduce((a, b) => a > b ? a : b);

    return _Panel(
      title: 'Attendance this week',
      subtitle: 'Employees present per day · out of ${overview.totalEmployees}',
      trailing: const _AttendanceLegend(),
      child: SizedBox(
        height: 168,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var wd = 1; wd <= 7; wd++)
              Expanded(
                child: _DayBar(
                  label: _weekdayLabels[wd - 1],
                  value: values[wd]!,
                  maxValue: maxValue,
                  hasData: hasData[wd]!,
                  highlight: wd == todayWeekday,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DayBar extends StatelessWidget {
  final String label;
  final int value;
  final int maxValue;
  final bool hasData;
  final bool highlight;

  const _DayBar({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.hasData,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    const maxBarHeight = 108.0;
    final ratio = maxValue == 0 ? 0.0 : (value / maxValue).clamp(0.0, 1.0);
    final barHeight = hasData ? (ratio * maxBarHeight).clamp(8.0, maxBarHeight) : 6.0;
    final barColor = !hasData
        ? AnalyticsDesktopTheme.border
        : (highlight ? AnalyticsOverviewPalette.sageGreen : AnalyticsDesktopTheme.purple);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          height: 22,
          child: hasData
              ? Center(
                  child: Text('$value', style: AnalyticsDesktopTheme.tableCellBold),
                )
              : null,
        ),
        Container(
          width: 28,
          height: barHeight,
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: AnalyticsDesktopTheme.bodySm.copyWith(fontSize: 12)),
      ],
    );
  }
}

class _AttendanceLegend extends StatelessWidget {
  const _AttendanceLegend();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        _LegendDot(color: AnalyticsDesktopTheme.purple, label: 'Present'),
        SizedBox(width: 12),
        _LegendDot(color: AnalyticsDesktopTheme.border, label: 'Absent'),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: AnalyticsDesktopTheme.bodySm.copyWith(fontSize: 12)),
      ],
    );
  }
}

/// Employee weekly summary — same data as the Attendance tab's weekly summary.
class _WeeklySummaryPanel extends StatelessWidget {
  final WeeklyAttendanceModel? weeklyAttendance;

  const _WeeklySummaryPanel({required this.weeklyAttendance});

  String _weekLabel(WeeklyAttendanceModel model) {
    if (model.weekStart != null && model.weekEnd != null) {
      try {
        final start = AnalyticsDateUtils.parseApiDate(model.weekStart!);
        final end = AnalyticsDateUtils.parseApiDate(model.weekEnd!);
        final fmt = DateFormat('d MMM');
        return 'Week ${model.week} · ${fmt.format(start)} – ${fmt.format(end)} ${start.year}';
      } catch (_) {
        return IsoWeek.weekPickerLabel(model.year, model.week);
      }
    }
    return IsoWeek.weekPickerLabel(model.year, model.week);
  }

  @override
  Widget build(BuildContext context) {
    final model = weeklyAttendance;
    final rows = model?.summaryRows ?? const <WeeklyAttendanceSummaryRow>[];

    return _Panel(
      title: 'Weekly summary',
      subtitle: model == null
          ? null
          : '${_weekLabel(model)} · max ${model.maxDailyHours.toStringAsFixed(0)}h/day (server cap)',
      badgeCount: rows.isEmpty ? null : rows.length,
      child: model == null
          ? const _EmptyRow(
              icon: AnalyticsIconType.calendar,
              message: 'Loading…',
            )
          : rows.isEmpty
              ? const _EmptyRow(
                  icon: AnalyticsIconType.calendar,
                  message: 'No attendance summary for this week',
                )
              : SizedBox(
                  height: _overviewSummaryTableHeight,
                  child: _OverviewSummaryTable(rows: rows),
                ),
    );
  }
}

class _OverviewSummaryTable extends StatelessWidget {
  final List<WeeklyAttendanceSummaryRow> rows;

  const _OverviewSummaryTable({required this.rows});

  @override
  Widget build(BuildContext context) {
    final tableRows = rows
        .map(
          (r) => AnalyticsTableRow([
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(r.employeeName, style: AnalyticsDesktopTheme.tableCellBold),
                if (r.employeeCode != null && r.employeeCode!.isNotEmpty)
                  Text(
                    r.employeeCode!,
                    style: AnalyticsDesktopTheme.bodySm.copyWith(fontSize: 11),
                  ),
              ],
            ),
            Text('${r.daysPresent}', style: AnalyticsDesktopTheme.tableCellStyle),
            Text(
              AnalyticsHours.format(r.totalWorkedHours),
              style: AnalyticsDesktopTheme.tableCellBold,
            ),
          ]),
        )
        .toList();

    return AnalyticsEnterpriseTable(
      recordLabel: 'employees',
      columnFlex: summaryColumnFlex,
      pageSize: _overviewPageSize,
      columns: const ['Name', 'Days present', 'Total worked'],
      rows: tableRows,
    );
  }
}

class _OverviewListPager extends StatelessWidget {
  final int page;
  final int totalPages;
  final int totalCount;
  final int pageSize;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const _OverviewListPager({
    required this.page,
    required this.totalPages,
    required this.totalCount,
    required this.pageSize,
    required this.onPrevious,
    required this.onNext,
  });

  int get _rangeStart => totalCount == 0 ? 0 : (page * pageSize) + 1;

  int get _rangeEnd {
    if (totalCount == 0) return 0;
    final end = (page + 1) * pageSize;
    return end > totalCount ? totalCount : end;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AnalyticsDesktopTheme.border)),
      ),
      child: Row(
        children: [
          Text(
            'Showing $_rangeStart–$_rangeEnd of $totalCount',
            style: AnalyticsDesktopTheme.bodySm.copyWith(fontSize: 12),
          ),
          const Spacer(),
          _OverviewPagerButton(
            label: 'Previous',
            enabled: onPrevious != null,
            onTap: onPrevious,
          ),
          const SizedBox(width: 8),
          Text(
            '${page + 1} / $totalPages',
            style: AnalyticsDesktopTheme.bodySm.copyWith(fontSize: 12),
          ),
          const SizedBox(width: 8),
          _OverviewPagerButton(
            label: 'Next',
            enabled: onNext != null,
            onTap: onNext,
          ),
        ],
      ),
    );
  }
}

class _OverviewPagerButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback? onTap;

  const _OverviewPagerButton({
    required this.label,
    required this.enabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: enabled ? onTap : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: AnalyticsDesktopTheme.purple,
        disabledForegroundColor: AnalyticsDesktopTheme.labelMuted,
        side: BorderSide(
          color: enabled
              ? AnalyticsDesktopTheme.purpleBorder
              : AnalyticsDesktopTheme.border,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Replaces the reference mockup's "pending approvals" panel — this is a
/// read-only roster of who's out today, not an approve/decline queue.
class _OnLeaveTodayPanel extends StatefulWidget {
  final LeaveAnalyticsResponse? leaveAnalytics;
  const _OnLeaveTodayPanel({required this.leaveAnalytics});

  @override
  State<_OnLeaveTodayPanel> createState() => _OnLeaveTodayPanelState();
}

class _OnLeaveTodayPanelState extends State<_OnLeaveTodayPanel> {
  int _page = 0;

  @override
  void didUpdateWidget(covariant _OnLeaveTodayPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.leaveAnalytics != widget.leaveAnalytics) {
      _page = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final employees =
        widget.leaveAnalytics?.onLeaveTodayEmployees ?? const <OnLeaveTodayEmployee>[];
    final totalPages = employees.isEmpty
        ? 1
        : (employees.length / _overviewPageSize).ceil();
    final page = _page.clamp(0, totalPages - 1);

    final start = page * _overviewPageSize;
    final pageEmployees = employees.isEmpty
        ? const <OnLeaveTodayEmployee>[]
        : employees.sublist(
            start,
            (start + _overviewPageSize).clamp(0, employees.length),
          );

    return _Panel(
      title: 'On leave today',
      badgeCount: employees.isEmpty ? null : employees.length,
      child: employees.isEmpty
          ? _EmptyRow(
              icon: AnalyticsIconType.onLeave,
              message: widget.leaveAnalytics == null
                  ? 'Loading…'
                  : 'No one is on leave today',
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < pageEmployees.length; i++) ...[
                  if (i > 0)
                    const Divider(height: 16, color: AnalyticsDesktopTheme.border),
                  _OnLeaveRow(employee: pageEmployees[i], compact: true),
                ],
                if (employees.length > _overviewPageSize)
                  _OverviewListPager(
                    page: page,
                    totalPages: totalPages,
                    totalCount: employees.length,
                    pageSize: _overviewPageSize,
                    onPrevious: page > 0 ? () => setState(() => _page -= 1) : null,
                    onNext: page < totalPages - 1
                        ? () => setState(() => _page += 1)
                        : null,
                  ),
              ],
            ),
    );
  }
}

class _OnLeaveRow extends StatelessWidget {
  final OnLeaveTodayEmployee employee;
  final bool compact;
  const _OnLeaveRow({required this.employee, this.compact = false});

  String get _initials {
    final parts = employee.employeeName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts.first[0];
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return '$first$last'.toUpperCase();
  }

  String? _fmt(String raw) {
    if (raw.isEmpty) return null;
    final d = DateTime.tryParse(raw);
    return d == null ? raw : DateFormat('d MMM').format(d);
  }

  String get _dateRange {
    final start = _fmt(employee.startDate);
    final end = _fmt(employee.endDate);
    if (start == null) return '';
    if (end == null || end == start) return start;
    return '$start – $end';
  }

  @override
  Widget build(BuildContext context) {
    final subtitleParts = [
      if ((employee.leaveType ?? '').isNotEmpty) employee.leaveType!,
      _dateRange,
    ].where((s) => s.isNotEmpty).join(' · ');
    final avatarRadius = compact ? 15.0 : 18.0;

    return Row(
      children: [
        CircleAvatar(
          radius: avatarRadius,
          backgroundColor: AnalyticsDesktopTheme.purpleLight,
          child: Text(
            _initials,
            style: TextStyle(
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w700,
              color: AnalyticsDesktopTheme.purpleDark,
            ),
          ),
        ),
        SizedBox(width: compact ? 10 : 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                employee.employeeName,
                style: AnalyticsDesktopTheme.tableCellBold,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitleParts.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  subtitleParts,
                  style: AnalyticsDesktopTheme.bodySm.copyWith(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Replaces the reference mockup's full "tasks pending" list — filtered to
/// only what's actually overdue (due date before today, not completed).
class _OverdueTasksPanel extends StatelessWidget {
  final List<Task>? tasks;
  final bool loading;
  const _OverdueTasksPanel({required this.tasks, required this.loading});

  @override
  Widget build(BuildContext context) {
    final list = tasks ?? const <Task>[];
    return _Panel(
      title: 'Overdue tasks',
      badgeCount: list.isEmpty ? null : list.length,
      child: list.isEmpty
          ? _EmptyRow(
              icon: AnalyticsIconType.checkCircle,
              message: tasks == null ? 'Loading…' : 'Nothing overdue',
            )
          : Column(
              children: [
                for (var i = 0; i < list.length; i++) ...[
                  if (i > 0)
                    const Divider(height: 20, color: AnalyticsDesktopTheme.border),
                  _OverdueTaskRow(task: list[i]),
                ],
              ],
            ),
    );
  }
}

class _OverdueTaskRow extends StatelessWidget {
  final Task task;
  const _OverdueTaskRow({required this.task});

  int? get _daysOverdue {
    final due = DateTime.tryParse(task.dueDate ?? '');
    if (due == null) return null;
    final today = DateTime.now();
    return DateTime(today.year, today.month, today.day)
        .difference(DateTime(due.year, due.month, due.day))
        .inDays;
  }

  Color get _priorityColor {
    switch (task.priority.toUpperCase()) {
      case 'HIGH':
        return AnalyticsDesktopTheme.danger;
      case 'LOW':
        return AnalyticsDesktopTheme.textMuted;
      default:
        return AnalyticsDesktopTheme.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final days = _daysOverdue;
    final overdueLabel = days != null && days > 0
        ? '$days day${days > 1 ? 's' : ''} overdue · ${task.assignedToName}'
        : 'Overdue · ${task.assignedToName}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: AnalyticsIcon(
            type: AnalyticsIconType.hourglass,
            size: 18,
            color: AnalyticsDesktopTheme.danger,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title.isEmpty ? 'Untitled task' : task.title,
                style: AnalyticsDesktopTheme.tableCellBold,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                overdueLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AnalyticsDesktopTheme.danger,
                ),
              ),
            ],
          ),
        ),
        if (task.priority.isNotEmpty) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _priorityColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              task.priority.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: _priorityColor,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
