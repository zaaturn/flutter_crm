import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../bloc/analytics_event.dart';
import '../../../models/weekly_attendance_model.dart';
import '../../../theme/analytics_theme.dart';
import '../../../utils/analytics_date_utils.dart';
import '../../../utils/analytics_hours.dart';
import '../../../utils/analytics_time.dart';
import '../../../utils/iso_week.dart';
import '../../mobile/mobile_attendance_daily_list.dart';
import '../analytics_enterprise_table.dart';
import '../analytics_loading_widgets.dart';

class WeeklyAttendanceTab extends StatelessWidget {
  final WeeklyAttendanceModel? data;
  final WeeklyAttendanceSubview subview;
  final String? dayFilterKey;
  final bool mobile;
  final Future<void> Function()? onRefresh;

  const WeeklyAttendanceTab({
    super.key,
    this.data,
    this.subview = WeeklyAttendanceSubview.daily,
    this.dayFilterKey,
    this.mobile = false,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final model = data;
    if (model == null) {
      return const Center(child: Text('No attendance data'));
    }

    final weekLabel = model.weekStart != null && model.weekEnd != null
        ? 'Week ${model.week} · ${_fmtRange(model.weekStart!, model.weekEnd!)}'
        : IsoWeek.weekPickerLabel(model.year, model.week);

    Widget body;
    if (subview == WeeklyAttendanceSubview.weeklySummary) {
      if (mobile) {
        body = MobileAttendanceSummaryList(rows: model.summaryRows);
      } else {
        body = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionHeader(
              title: weekLabel,
              subtitle:
                  'Employee weekly summary · max ${model.maxDailyHours.toStringAsFixed(0)}h/day (server cap)',
              mobile: mobile,
            ),
            Expanded(
              child: SizedBox.expand(
                child: _SummaryTable(rows: model.summaryRows, mobile: mobile),
              ),
            ),
          ],
        );
      }
    } else {
      final dayKey = dayFilterKey ??
          AnalyticsDateUtils.defaultDayKeyForIsoWeek(model.year, model.week);
      final rows = model.filteredDailyRows(dayKey: dayKey);
      if (mobile) {
        body = MobileAttendanceDailyList(
          rows: rows,
          year: model.year,
          week: model.week,
          dayKey: dayKey,
        );
      } else {
        body = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionHeader(
              title: weekLabel,
              subtitle:
                  '${_dayLabel(model.week, dayKey)} · ${rows.length} employees',
              mobile: mobile,
            ),
            Expanded(
              child: SizedBox.expand(
                child: _DailyTable(rows: rows, mobile: mobile),
              ),
            ),
          ],
        );
      }
    }

    if (onRefresh == null || !mobile) return body;
    return AnalyticsRefreshable(
      mobile: mobile,
      onRefresh: onRefresh!,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [SliverFillRemaining(child: body)],
      ),
    );
  }

  String _fmtRange(String start, String end) {
    try {
      final s = AnalyticsDateUtils.parseApiDate(start);
      final e = AnalyticsDateUtils.parseApiDate(end);
      final fmt = DateFormat('d MMM');
      return '${fmt.format(s)} – ${fmt.format(e)} ${s.year}';
    } catch (_) {
      return '$start – $end';
    }
  }

  String _dayLabel(int week, String dayKey) {
    final date = AnalyticsDateUtils.parseApiDate(dayKey);
    return 'W$week ${DateFormat('EEEE').format(date)} · ${DateFormat('dd MMM yyyy').format(date)}';
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool mobile;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.mobile,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(mobile ? 16 : 20, mobile ? 12 : 16, mobile ? 16 : 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AnalyticsDesktopTheme.titleLg),
          const SizedBox(height: 4),
          Text(subtitle, style: AnalyticsDesktopTheme.bodySm),
        ],
      ),
    );
  }
}

class _DailyTable extends StatelessWidget {
  final List<WeeklyAttendanceDayRow> rows;
  final bool mobile;

  const _DailyTable({required this.rows, required this.mobile});

  @override
  Widget build(BuildContext context) {
    final tableRows = rows.map((r) {
      final dateStr =
          r.date != null ? DateFormat('dd MMM yyyy').format(r.date!) : '—';
      return AnalyticsTableRow([
        _nameCell(r),
        Text(dateStr, style: AnalyticsDesktopTheme.tableCellStyle),
        Text(
          AnalyticsTime.format(r.checkIn) ?? '—',
          style: AnalyticsDesktopTheme.tableCellStyle,
        ),
        Text(
          AnalyticsTime.format(r.checkOut) ?? '—',
          style: AnalyticsDesktopTheme.tableCellStyle,
        ),
        Text(
          AnalyticsHours.format(r.cappedHours),
          style: AnalyticsDesktopTheme.tableCellBold,
        ),
        AnalyticsStatusPill(status: r.status, onLeave: r.onLeave),
      ]);
    }).toList();

    return AnalyticsEnterpriseTable(
        mobile: mobile,
        recordLabel: 'employees',
        columnFlex: attendanceColumnFlex,
        columns: const [
          'Name',
          'Date',
          'Check-in',
          'Check-out',
          'Hours',
          'Status',
        ],
        rows: tableRows,
      );
  }

  Widget _nameCell(WeeklyAttendanceDayRow r) {
    return Column(
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
    );
  }
}

class _SummaryTable extends StatelessWidget {
  final List<WeeklyAttendanceSummaryRow> rows;
  final bool mobile;

  const _SummaryTable({required this.rows, required this.mobile});

  @override
  Widget build(BuildContext context) {
    final tableRows = rows
        .map(
          (r) => AnalyticsTableRow([
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
        mobile: mobile,
        recordLabel: 'employees',
        columnFlex: summaryColumnFlex,
        columns: const ['Name', 'Days present', 'Total worked'],
        rows: tableRows,
      );
  }
}
