import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/attendance_summary_model.dart';
import '../../theme/analytics_theme.dart';
import '../../utils/analytics_hours.dart';

class EmployeeSummaryTable extends StatelessWidget {
  final AttendanceSummaryModel data;
  final bool mobile;

  const EmployeeSummaryTable({
    super.key,
    required this.data,
    this.mobile = false,
  });

  @override
  Widget build(BuildContext context) {
    if (data.rows.isEmpty) {
      return const Center(child: Text('No employees in this date range'));
    }

    final border = mobile ? Colors.transparent : AnalyticsDesktopTheme.border;
    final surface = mobile ? AnalyticsMobileTheme.card : AnalyticsDesktopTheme.surface;

    return Padding(
      padding: EdgeInsets.all(mobile ? 16 : 24),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.sizeOf(context).width - (mobile ? 32 : 48),
              ),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(2.2),
                  1: FlexColumnWidth(1.2),
                  2: FlexColumnWidth(1.6),
                  3: FlexColumnWidth(1.2),
                  4: FlexColumnWidth(1.2),
                  5: FlexColumnWidth(1.4),
                },
                border: TableBorder(
                  horizontalInside: BorderSide(color: border),
                ),
                children: [
                  _headerRow(mobile),
                  ...data.rows.map(_dataRow),
                  _footerRow(mobile),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  TableRow _headerRow(bool mobile) {
    final color = mobile
        ? AnalyticsMobileTheme.terracotta.withValues(alpha: 0.12)
        : AnalyticsDesktopTheme.purpleLight;
    return TableRow(
      decoration: BoxDecoration(color: color),
      children: [
        _cell('Employee Name', header: true),
        _cell('Code', header: true),
        _cell('Department', header: true),
        _cell('Days Present', header: true),
        _cell('Leave Taken', header: true),
        _cell('Total Worked', header: true),
      ],
    );
  }

  TableRow _dataRow(AttendanceSummaryRow row) {
    return TableRow(
      children: [
        _cell(row.employeeName),
        _cell(row.employeeCode ?? '—'),
        _cell(row.department ?? '—'),
        _cell('${row.daysPresent}'),
        _cell(row.leaveTakenDays.toStringAsFixed(1)),
        _cell(AnalyticsHours.format(row.totalWorkedHours)),
      ],
    );
  }

  TableRow _footerRow(bool mobile) {
    final color = mobile
        ? AnalyticsMobileTheme.terracotta.withValues(alpha: 0.08)
        : AnalyticsDesktopTheme.purpleLight.withValues(alpha: 0.5);
    return TableRow(
      decoration: BoxDecoration(color: color),
      children: [
        _cell('Total (${data.employeeCount} employees)', bold: true),
        _cell(''),
        _cell(''),
        _cell(''),
        _cell(data.totalLeaveTaken.toStringAsFixed(1), bold: true),
        _cell(AnalyticsHours.format(data.totalWorkedHours), bold: true),
      ],
    );
  }

  Widget _cell(String text, {bool header = false, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Text(
        text,
        style: GoogleFonts.manrope(
          fontSize: header ? 11 : 13,
          fontWeight: header || bold ? FontWeight.w800 : FontWeight.w600,
          color: header
              ? AnalyticsDesktopTheme.textMuted
              : AnalyticsDesktopTheme.textMain,
          letterSpacing: header ? 0.4 : 0,
        ),
      ),
    );
  }
}
