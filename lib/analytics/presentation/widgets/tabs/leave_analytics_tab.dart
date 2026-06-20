import 'package:flutter/material.dart';

import '../../../models/leave_analytics_model.dart';
import '../../../theme/analytics_theme.dart';
import '../analytics_loading_widgets.dart';

/// Shows employees on leave today — name and leave type only.
class LeaveAnalyticsTab extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final model = data;
    if (model == null) {
      return const Center(child: Text('No leave data'));
    }

    final employees = model.onLeaveTodayEmployees;

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            mobile ? 16 : 20,
            mobile ? 12 : 16,
            mobile ? 16 : 20,
            12,
          ),
          child: Text('On leave today', style: AnalyticsDesktopTheme.titleLg),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: mobile ? 16 : 20),
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
                      _OnLeaveRow(employee: employees[index], mobile: mobile),
                ),
        ),
      ],
    );

    if (onRefresh == null || !mobile) {
      return SizedBox.expand(child: body);
    }

    return AnalyticsRefreshable(
      mobile: mobile,
      onRefresh: onRefresh!,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [SliverFillRemaining(child: body)],
      ),
    );
  }
}

class _OnLeaveRow extends StatelessWidget {
  final OnLeaveTodayEmployee employee;
  final bool mobile;

  const _OnLeaveRow({required this.employee, required this.mobile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: mobile ? 16 : 20,
        vertical: 14,
      ),
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
