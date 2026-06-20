import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/analytics_bloc.dart';
import '../../bloc/analytics_event.dart';
import '../../bloc/analytics_state.dart';
import 'analytics_loading_widgets.dart';
import 'tabs/leave_analytics_tab.dart';
import 'tabs/monthly_billing_tab.dart';
import 'tabs/overview_tab.dart';
import 'tabs/weekly_attendance_tab.dart';
import 'tabs/weekly_business_tab.dart';

/// Resolves loading shimmer, error+retry, and tab content for analytics screens.
class AnalyticsTabBody extends StatelessWidget {
  final AnalyticsState state;
  final bool mobile;

  const AnalyticsTabBody({
    super.key,
    required this.state,
    this.mobile = false,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isForbidden) {
      return const SizedBox.shrink();
    }

    if (state.isLoading) {
      return state.tab == AnalyticsTab.overview
          ? AnalyticsShimmerGrid(mobile: mobile)
          : const AnalyticsShimmerList();
    }

    if (_isError(state)) {
      return AnalyticsErrorRetry(
        mobile: mobile,
        message: state.errorMessage,
        onRetry: () => context.read<AnalyticsBloc>().add(const AnalyticsRefreshed()),
      );
    }

    return _content(context, state);
  }

  bool _isError(AnalyticsState state) {
    if (state.errorMessage == null || state.isForbidden) return false;
    return switch (state.tab) {
      AnalyticsTab.overview => state.overview == null,
      AnalyticsTab.employeeSummary => state.attendanceSummary == null,
      AnalyticsTab.weeklyAttendance => state.attendance == null,
      AnalyticsTab.weeklyBusiness => state.business == null,
      AnalyticsTab.monthlyBilling => state.billing == null,
      AnalyticsTab.leaves => state.leaveAnalytics == null,
    };
  }

  Widget _content(BuildContext context, AnalyticsState state) {
    Future<void> refresh() async {
      final bloc = context.read<AnalyticsBloc>();
      bloc.add(const AnalyticsRefreshed());
      await bloc.stream.firstWhere((s) => !s.isLoading);
    }

    switch (state.tab) {
      case AnalyticsTab.overview:
        return OverviewTab(
          overview: state.overview,
          mobile: mobile,
          onRefresh: refresh,
        );
      case AnalyticsTab.employeeSummary:
        return const Center(child: Text('Use Overview or Attendance tabs'));
      case AnalyticsTab.weeklyAttendance:
        return SizedBox.expand(
          child: WeeklyAttendanceTab(
            data: state.attendance,
            subview: state.attendanceSubview,
            dayFilterKey: state.attendanceDayFilter,
            mobile: mobile,
            onRefresh: refresh,
          ),
        );
      case AnalyticsTab.weeklyBusiness:
        return WeeklyBusinessTab(
          data: state.business,
          mobile: mobile,
          onRefresh: refresh,
        );
      case AnalyticsTab.monthlyBilling:
        return SizedBox.expand(
          child: MonthlyBillingTab(
            data: state.billing,
            mobile: mobile,
            onRefresh: refresh,
          ),
        );
      case AnalyticsTab.leaves:
        return SizedBox.expand(
          child: LeaveAnalyticsTab(
            data: state.leaveAnalytics,
            mobile: mobile,
            onRefresh: refresh,
          ),
        );
    }
  }
}
