import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../models/weekly_attendance_model.dart';
import '../../theme/analytics_theme.dart';
import '../../utils/analytics_date_utils.dart';
import '../../utils/analytics_hours.dart';
import 'mobile_attendance_employee_card.dart';

const int _kAttendancePageSize = 10;

/// Mobile daily attendance — 10 employees per page, no search bar.
class MobileAttendanceDailyList extends StatefulWidget {
  const MobileAttendanceDailyList({
    super.key,
    required this.rows,
    required this.year,
    required this.week,
    this.dayKey,
  });

  final List<WeeklyAttendanceDayRow> rows;
  final int year;
  final int week;
  final String? dayKey;

  @override
  State<MobileAttendanceDailyList> createState() =>
      _MobileAttendanceDailyListState();
}

class _MobileAttendanceDailyListState extends State<MobileAttendanceDailyList> {
  int _page = 0;

  @override
  void didUpdateWidget(covariant MobileAttendanceDailyList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rows != widget.rows ||
        oldWidget.dayKey != widget.dayKey ||
        oldWidget.week != widget.week) {
      _page = 0;
    }
  }

  int get _totalPages {
    if (widget.rows.isEmpty) return 1;
    return (widget.rows.length / _kAttendancePageSize).ceil();
  }

  List<WeeklyAttendanceDayRow> get _pageRows {
    final start = _page * _kAttendancePageSize;
    if (start >= widget.rows.length) return [];
    final end = (start + _kAttendancePageSize).clamp(0, widget.rows.length);
    return widget.rows.sublist(start, end);
  }

  String get _dayTitle {
    final key = widget.dayKey ??
        AnalyticsDateUtils.defaultDayKeyForIsoWeek(widget.year, widget.week);
    try {
      final date = AnalyticsDateUtils.parseApiDate(key);
      return DateFormat('EEEE, dd MMM').format(date);
    } catch (_) {
      return 'Selected day';
    }
  }

  @override
  Widget build(BuildContext context) {
    final rows = _pageRows;
    final total = widget.rows.length;
    final rangeStart = total == 0 ? 0 : (_page * _kAttendancePageSize) + 1;
    final rangeEnd = total == 0
        ? 0
        : (rangeStart + rows.length - 1).clamp(0, total);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _dayTitle,
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AnalyticsMobileTheme.textDark,
                  ),
                ),
              ),
              Text(
                '$total employees',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: AnalyticsMobileTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: total == 0
              ? Center(
                  child: Text(
                    'No attendance records for this day',
                    style: GoogleFonts.manrope(
                      color: AnalyticsMobileTheme.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                  itemCount: rows.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) =>
                      MobileAttendanceEmployeeCard(row: rows[index]),
                ),
        ),
        if (total > _kAttendancePageSize)
          _AttendancePaginationBar(
            page: _page,
            totalPages: _totalPages,
            rangeLabel: '$rangeStart–$rangeEnd of $total',
            onPrevious: _page > 0
                ? () => setState(() => _page--)
                : null,
            onNext: _page < _totalPages - 1
                ? () => setState(() => _page++)
                : null,
          ),
      ],
    );
  }
}

/// Mobile weekly summary — 10 employees per page, no search bar.
class MobileAttendanceSummaryList extends StatefulWidget {
  const MobileAttendanceSummaryList({super.key, required this.rows});

  final List<WeeklyAttendanceSummaryRow> rows;

  @override
  State<MobileAttendanceSummaryList> createState() =>
      _MobileAttendanceSummaryListState();
}

class _MobileAttendanceSummaryListState
    extends State<MobileAttendanceSummaryList> {
  int _page = 0;

  @override
  void didUpdateWidget(covariant MobileAttendanceSummaryList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rows != widget.rows) _page = 0;
  }

  int get _totalPages {
    if (widget.rows.isEmpty) return 1;
    return (widget.rows.length / _kAttendancePageSize).ceil();
  }

  List<WeeklyAttendanceSummaryRow> get _pageRows {
    final start = _page * _kAttendancePageSize;
    if (start >= widget.rows.length) return [];
    final end = (start + _kAttendancePageSize).clamp(0, widget.rows.length);
    return widget.rows.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    final rows = _pageRows;
    final total = widget.rows.length;
    final rangeStart = total == 0 ? 0 : (_page * _kAttendancePageSize) + 1;
    final rangeEnd = total == 0
        ? 0
        : (rangeStart + rows.length - 1).clamp(0, total);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Weekly summary',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AnalyticsMobileTheme.textDark,
                  ),
                ),
              ),
              Text(
                '$total employees',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: AnalyticsMobileTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
            itemCount: rows.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) => _SummaryCard(row: rows[index]),
          ),
        ),
        if (total > _kAttendancePageSize)
          _AttendancePaginationBar(
            page: _page,
            totalPages: _totalPages,
            rangeLabel: '$rangeStart–$rangeEnd of $total',
            onPrevious: _page > 0
                ? () => setState(() => _page--)
                : null,
            onNext: _page < _totalPages - 1
                ? () => setState(() => _page++)
                : null,
          ),
      ],
    );
  }
}

class _AttendancePaginationBar extends StatelessWidget {
  const _AttendancePaginationBar({
    required this.page,
    required this.totalPages,
    required this.rangeLabel,
    required this.onPrevious,
    required this.onNext,
  });

  final int page;
  final int totalPages;
  final String rangeLabel;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 4, 14, 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AnalyticsMobileTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AnalyticsMobileTheme.border),
      ),
      child: Row(
        children: [
          _navButton(
            icon: Icons.chevron_left_rounded,
            onTap: onPrevious,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Page ${page + 1} of $totalPages',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: AnalyticsMobileTheme.textDark,
                  ),
                ),
                Text(
                  rangeLabel,
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    color: AnalyticsMobileTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          _navButton(
            icon: Icons.chevron_right_rounded,
            onTap: onNext,
          ),
        ],
      ),
    );
  }

  Widget _navButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    final enabled = onTap != null;
    return Material(
      color: enabled
          ? AnalyticsMobileTheme.terracotta.withValues(alpha: 0.12)
          : AnalyticsMobileTheme.field,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            icon,
            size: 22,
            color: enabled
                ? AnalyticsMobileTheme.terracotta
                : AnalyticsMobileTheme.textMuted.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.row});

  final WeeklyAttendanceSummaryRow row;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AnalyticsMobileTheme.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.employeeName,
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                if (row.employeeCode != null && row.employeeCode!.isNotEmpty)
                  Text(
                    row.employeeCode!,
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AnalyticsMobileTheme.textMuted,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${row.daysPresent} days',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              Text(
                AnalyticsHours.format(row.totalWorkedHours),
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: AnalyticsMobileTheme.terracotta,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
