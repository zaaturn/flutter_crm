import '../models/analytics_overview_model.dart';

import '../models/attendance_summary_model.dart';

import '../models/leave_analytics_model.dart';
import '../models/leave_summary_model.dart';

import '../models/monthly_billing_model.dart';

import '../models/weekly_attendance_model.dart';

import '../models/weekly_business_model.dart';

import '../services/analytics_api_service.dart';



class AnalyticsRepository {

  AnalyticsRepository({AnalyticsApiService? api})

      : _api = api ?? AnalyticsApiService();



  final AnalyticsApiService _api;



  Future<AnalyticsOverviewModel> loadOverview() => _api.fetchOverview();



  Future<AttendanceSummaryModel> loadAttendanceSummary({

    required String start,

    required String end,

  }) =>

      _api.fetchAttendanceSummary(start: start, end: end);



  Future<WeeklyAttendanceModel> loadWeeklyAttendance({

    int? year,

    int? week,

  }) =>

      _api.fetchWeeklyAttendance(year: year, week: week);



  Future<WeeklyBusinessModel> loadWeeklyBusiness({

    int? year,

    int? week,

  }) =>

      _api.fetchWeeklyBusiness(year: year, week: week);



  Future<MonthlyBillingModel> loadMonthlyBilling({required int year}) =>

      _api.fetchMonthlyBilling(year: year);



  Future<LeaveSummaryModel> loadLeaveSummary({

    int? year,

    int? month,

  }) =>

      _api.fetchLeaveSummary(year: year, month: month);



  Future<LeaveAnalyticsResponse> loadLeaveAnalytics({

    int? year,

    int? month,

    String? status,

  }) =>

      _api.getLeaveAnalytics(year: year, month: month, status: status);

}


