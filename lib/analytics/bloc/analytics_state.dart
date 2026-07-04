import 'package:equatable/equatable.dart';

import 'package:my_app/admin_dashboard/model/task.dart';

import '../models/analytics_overview_model.dart';

import '../models/attendance_summary_model.dart';

import '../models/leave_analytics_model.dart';
import '../models/leave_summary_model.dart';

import '../models/monthly_billing_model.dart';

import '../models/weekly_attendance_model.dart';

import '../models/weekly_business_model.dart';

import '../utils/analytics_date_utils.dart';

import '../utils/analytics_exceptions.dart';

import '../utils/iso_week.dart';

import 'analytics_event.dart';



class AnalyticsState extends Equatable {

  final AnalyticsTab tab;

  final int year;

  final int week;

  final int billingYear;



  final DateRangePreset summaryPreset;

  final DateTime summaryStart;

  final DateTime summaryEnd;



  /// Selected day in daily attendance view (`YYYY-MM-DD`). Always set for daily subview.
  final String? attendanceDayFilter;

  final WeeklyAttendanceSubview attendanceSubview;



  final bool overviewLoading;

  final bool summaryLoading;

  final bool attendanceLoading;

  final bool businessLoading;

  final bool billingLoading;

  final bool leaveLoading;

  final bool tasksLoading;



  final AnalyticsOverviewModel? overview;

  final AttendanceSummaryModel? attendanceSummary;

  final WeeklyAttendanceModel? attendance;

  final WeeklyBusinessModel? business;

  final MonthlyBillingModel? billing;

  final LeaveSummaryModel? leaveSummary;

  final LeaveAnalyticsResponse? leaveAnalytics;

  /// `null` = not fetched yet; overview's overdue-tasks panel (pulled from
  /// the admin tasks module, not analytics' own endpoint).
  final List<Task>? overdueTasks;



  final String? errorMessage;

  final AnalyticsErrorKind? errorKind;



  const AnalyticsState({

    this.tab = AnalyticsTab.overview,

    required this.year,

    required this.week,

    required this.billingYear,

    required this.summaryPreset,

    required this.summaryStart,

    required this.summaryEnd,

    this.attendanceDayFilter,

    this.attendanceSubview = WeeklyAttendanceSubview.daily,

    this.overviewLoading = false,

    this.summaryLoading = false,

    this.attendanceLoading = false,

    this.businessLoading = false,

    this.billingLoading = false,

    this.leaveLoading = false,

    this.tasksLoading = false,

    this.overview,

    this.attendanceSummary,

    this.attendance,

    this.business,

    this.billing,

    this.leaveSummary,

    this.leaveAnalytics,

    this.overdueTasks,

    this.errorMessage,

    this.errorKind,

  });



  factory AnalyticsState.initial() {

    final now = IsoWeek.current();

    final monthRange = AnalyticsDateUtils.thisMonth();

    return AnalyticsState(

      year: now.year,

      week: now.week,

      billingYear: DateTime.now().year,

      summaryPreset: DateRangePreset.thisMonth,

      summaryStart: monthRange.start,

      summaryEnd: monthRange.end,

      attendanceDayFilter:

          AnalyticsDateUtils.defaultDayKeyForIsoWeek(now.year, now.week),

    );

  }



  bool get isForbidden => errorKind == AnalyticsErrorKind.forbidden;



  bool get isLoading {

    switch (tab) {

      case AnalyticsTab.overview:

        return overviewLoading && overview == null;

      case AnalyticsTab.employeeSummary:

        return summaryLoading && attendanceSummary == null;

      case AnalyticsTab.weeklyAttendance:

        return attendanceLoading && attendance == null;

      case AnalyticsTab.weeklyBusiness:

        return businessLoading && business == null;

      case AnalyticsTab.monthlyBilling:

        return billingLoading && billing == null;

      case AnalyticsTab.leaves:

        return leaveLoading && leaveAnalytics == null;

    }

  }



  AnalyticsState copyWith({

    AnalyticsTab? tab,

    int? year,

    int? week,

    int? billingYear,

    DateRangePreset? summaryPreset,

    DateTime? summaryStart,

    DateTime? summaryEnd,

    String? attendanceDayFilter,

    bool clearAttendanceDayFilter = false,

    WeeklyAttendanceSubview? attendanceSubview,

    bool? overviewLoading,

    bool? summaryLoading,

    bool? attendanceLoading,

    bool? businessLoading,

    bool? billingLoading,

    bool? leaveLoading,

    bool? tasksLoading,

    AnalyticsOverviewModel? overview,

    AttendanceSummaryModel? attendanceSummary,

    WeeklyAttendanceModel? attendance,

    WeeklyBusinessModel? business,

    MonthlyBillingModel? billing,

    LeaveSummaryModel? leaveSummary,

    LeaveAnalyticsResponse? leaveAnalytics,

    List<Task>? overdueTasks,

    String? errorMessage,

    AnalyticsErrorKind? errorKind,

    bool clearError = false,

    bool clearOverview = false,

    bool clearSummary = false,

    bool clearAttendance = false,

    bool clearBusiness = false,

    bool clearBilling = false,

    bool clearLeaveAnalytics = false,

  }) {

    return AnalyticsState(

      tab: tab ?? this.tab,

      year: year ?? this.year,

      week: week ?? this.week,

      billingYear: billingYear ?? this.billingYear,

      summaryPreset: summaryPreset ?? this.summaryPreset,

      summaryStart: summaryStart ?? this.summaryStart,

      summaryEnd: summaryEnd ?? this.summaryEnd,

      attendanceDayFilter: clearAttendanceDayFilter

          ? null

          : (attendanceDayFilter ?? this.attendanceDayFilter),

      attendanceSubview: attendanceSubview ?? this.attendanceSubview,

      overviewLoading: overviewLoading ?? this.overviewLoading,

      summaryLoading: summaryLoading ?? this.summaryLoading,

      attendanceLoading: attendanceLoading ?? this.attendanceLoading,

      businessLoading: businessLoading ?? this.businessLoading,

      billingLoading: billingLoading ?? this.billingLoading,

      leaveLoading: leaveLoading ?? this.leaveLoading,

      tasksLoading: tasksLoading ?? this.tasksLoading,

      overview: clearOverview ? null : (overview ?? this.overview),

      attendanceSummary:

          clearSummary ? null : (attendanceSummary ?? this.attendanceSummary),

      attendance: clearAttendance ? null : (attendance ?? this.attendance),

      business: clearBusiness ? null : (business ?? this.business),

      billing: clearBilling ? null : (billing ?? this.billing),

      leaveSummary: leaveSummary ?? this.leaveSummary,

      leaveAnalytics: clearLeaveAnalytics

          ? null

          : (leaveAnalytics ?? this.leaveAnalytics),

      overdueTasks: overdueTasks ?? this.overdueTasks,

      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),

      errorKind: clearError ? null : (errorKind ?? this.errorKind),

    );

  }



  @override

  List<Object?> get props => [

        tab,

        year,

        week,

        billingYear,

        summaryPreset,

        summaryStart,

        summaryEnd,

        attendanceDayFilter,

        attendanceSubview,

        overviewLoading,

        summaryLoading,

        attendanceLoading,

        businessLoading,

        billingLoading,

        leaveLoading,

        tasksLoading,

        overview,

        attendanceSummary,

        attendance,

        business,

        billing,

        leaveSummary,

        leaveAnalytics,

        overdueTasks,

        errorMessage,

        errorKind,

      ];

}


