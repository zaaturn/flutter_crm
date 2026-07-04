import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/leave_analytics_model.dart';
import '../../../theme/analytics_theme.dart';
import '../analytics_loading_widgets.dart';
import '../../mobile/mobile_leave_employee_card.dart';

const int _kLeavePageSize = 10;

/// Shows employees on leave today — mobile uses white cards, desktop uses table.
class LeaveAnalyticsTab extends StatefulWidget {
  final LeaveAnalyticsResponse? data;
  final bool mobile;
  final Future<void> Function()? onRefresh;

  const LeaveAnalyticsTab({
    super.key,
    this.data,
    this.mobile = false,
    this.onRefresh,
  });

  @override
  State<LeaveAnalyticsTab> createState() => _LeaveAnalyticsTabState();
}

class _LeaveAnalyticsTabState extends State<LeaveAnalyticsTab> {
  int _page = 0;

  @override
  void didUpdateWidget(covariant LeaveAnalyticsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) _page = 0;
  }

  @override
  Widget build(BuildContext context) {
    final model = widget.data;
    if (model == null) {
      return const Center(child: Text('No leave data'));
    }

    final body = widget.mobile
        ? _MobileLeaveBody(
            employees: model.onLeaveTodayEmployees,
            count: model.onLeaveToday,
            page: _page,
            onPageChanged: (p) => setState(() => _page = p),
          )
        : _DesktopLeaveBody(employees: model.onLeaveTodayEmployees);

    if (widget.onRefresh == null || !widget.mobile) {
      return SizedBox.expand(child: body);
    }

    return AnalyticsRefreshable(
      mobile: widget.mobile,
      onRefresh: widget.onRefresh!,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [SliverFillRemaining(child: body)],
      ),
    );
  }
}

class _MobileLeaveBody extends StatelessWidget {
  const _MobileLeaveBody({
    required this.employees,
    required this.count,
    required this.page,
    required this.onPageChanged,
  });

  final List<OnLeaveTodayEmployee> employees;
  final int count;
  final int page;
  final ValueChanged<int> onPageChanged;

  int get _totalPages {
    if (employees.isEmpty) return 1;
    return (employees.length / _kLeavePageSize).ceil();
  }

  List<OnLeaveTodayEmployee> get _pageRows {
    final start = page * _kLeavePageSize;
    if (start >= employees.length) return [];
    final end = (start + _kLeavePageSize).clamp(0, employees.length);
    return employees.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    final rows = _pageRows;
    final total = employees.length;
    final displayCount = count > 0 ? count : total;
    final rangeStart = total == 0 ? 0 : (page * _kLeavePageSize) + 1;
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
                  'On leave today',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AnalyticsMobileTheme.textDark,
                  ),
                ),
              ),
              Text(
                '$displayCount employees',
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
                    'No employees on leave today',
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
                      MobileLeaveEmployeeCard(employee: rows[index]),
                ),
        ),
        if (total > _kLeavePageSize)
          _LeavePaginationBar(
            page: page,
            totalPages: _totalPages,
            rangeLabel: '$rangeStart–$rangeEnd of $total',
            onPrevious:
                page > 0 ? () => onPageChanged(page - 1) : null,
            onNext: page < _totalPages - 1
                ? () => onPageChanged(page + 1)
                : null,
          ),
      ],
    );
  }
}

class _LeavePaginationBar extends StatelessWidget {
  const _LeavePaginationBar({
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
          _nav(Icons.chevron_left_rounded, onPrevious),
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
          _nav(Icons.chevron_right_rounded, onNext),
        ],
      ),
    );
  }

  Widget _nav(IconData icon, VoidCallback? onTap) {
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

class _DesktopLeaveBody extends StatelessWidget {
  const _DesktopLeaveBody({required this.employees});

  final List<OnLeaveTodayEmployee> employees;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Text('On leave today', style: AnalyticsDesktopTheme.titleLg),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: AnalyticsDesktopTheme.tableHeader,
              border: Border(
                bottom: BorderSide(color: AnalyticsDesktopTheme.border),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'EMPLOYEE NAME',
                      style: AnalyticsDesktopTheme.tableHeaderStyle,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'LEAVE TYPE',
                      style: AnalyticsDesktopTheme.tableHeaderStyle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: employees.isEmpty
              ? Center(
                  child: Text(
                    'No employees on leave today',
                    style: AnalyticsDesktopTheme.bodySm,
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: employees.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    color: AnalyticsDesktopTheme.border,
                  ),
                  itemBuilder: (context, index) =>
                      _DesktopLeaveRow(employee: employees[index]),
                ),
        ),
      ],
    );
  }
}

class _DesktopLeaveRow extends StatelessWidget {
  const _DesktopLeaveRow({required this.employee});

  final OnLeaveTodayEmployee employee;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.employeeName,
                  style: AnalyticsDesktopTheme.tableCellBold,
                ),
                if (employee.employeeCode != null &&
                    employee.employeeCode!.isNotEmpty)
                  Text(
                    employee.employeeCode!,
                    style: AnalyticsDesktopTheme.bodySm.copyWith(fontSize: 11),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              employee.leaveType?.trim().isNotEmpty == true
                  ? employee.leaveType!
                  : '—',
              style: AnalyticsDesktopTheme.tableCellStyle,
            ),
          ),
        ],
      ),
    );
  }
}
