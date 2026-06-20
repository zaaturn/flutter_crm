import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:my_app/services/api_client.dart';

import '../models/analytics_overview_model.dart';
import '../models/leave_analytics_model.dart';

import '../models/attendance_summary_model.dart';

import '../models/leave_summary_model.dart';

import '../models/monthly_billing_model.dart';

import '../models/weekly_attendance_model.dart';

import '../models/weekly_business_model.dart';

import '../utils/analytics_exceptions.dart';



/// Analytics HTTP layer — uses shared [ApiClient] Dio (JWT + refresh).

class AnalyticsApiService {

  AnalyticsApiService({Dio? dio}) : _dio = dio ?? ApiClient().dio;



  final Dio _dio;



  static const _base = '/api/analytics';



  Future<AnalyticsOverviewModel> fetchOverview() async {

    final res = await _get('$_base/overview/');

    return AnalyticsOverviewModel.fromJson(_asMap(res.data));

  }



  Future<AttendanceSummaryModel> fetchAttendanceSummary({

    required String start,

    required String end,

  }) async {

    final res = await _get(

      '$_base/attendance/summary/',

      query: {'start': start, 'end': end},

    );

    return AttendanceSummaryModel.fromJson(_asMap(res.data));

  }



  Future<WeeklyAttendanceModel> fetchWeeklyAttendance({

    int? year,

    int? week,

  }) async {

    final q = <String, dynamic>{};

    if (year != null) q['year'] = year;

    if (week != null) q['week'] = week;

    final res = await _get('$_base/attendance/weekly/', query: q);

    return WeeklyAttendanceModel.fromJson(

      _asMap(res.data),

      year: year ?? DateTime.now().year,

      week: week ?? 1,

    );

  }



  Future<WeeklyBusinessModel> fetchWeeklyBusiness({

    int? year,

    int? week,

  }) async {

    final q = <String, dynamic>{};

    if (year != null) q['year'] = year;

    if (week != null) q['week'] = week;

    final res = await _get('$_base/business/weekly/', query: q);

    return WeeklyBusinessModel.fromJson(

      _asMap(res.data),

      year: year ?? DateTime.now().year,

      week: week ?? 1,

    );

  }



  Future<MonthlyBillingModel> fetchMonthlyBilling({required int year}) async {

    final res = await _get('$_base/billing/monthly/', query: {'year': year});

    return MonthlyBillingModel.fromJson(_asMap(res.data), year: year);

  }



  Future<LeaveSummaryModel> fetchLeaveSummary({

    int? year,

    int? month,

  }) async {

    final data = await getLeaveAnalytics(year: year, month: month);

    return LeaveSummaryModel(

      year: data.year,

      month: data.month,

      period: data.period.isNotEmpty ? data.period : null,

      pending: data.pending,

      approved: data.approved,

      rejected: data.rejected,

      cancelled: data.cancelled,

      onLeaveToday: data.onLeaveToday,

    );

  }



  Future<LeaveAnalyticsResponse> getLeaveAnalytics({

    int? year,

    int? month,

    String? status,

  }) async {

    final now = DateTime.now();

    final y = year ?? now.year;

    final m = month ?? now.month;

    final q = <String, dynamic>{'year': y, 'month': m};

    if (status != null && status.isNotEmpty) q['status'] = status;

    final res = await _get('$_base/leave/', query: q);

    final parsed = LeaveAnalyticsResponse.fromJson(

      _asMap(res.data),

      year: y,

      month: m,

    );

    if (parsed.records.isNotEmpty) {

      debugPrint(

        'Leave analytics first record employee_name: ${parsed.records.first.employeeName}',

      );

    }

    return parsed;

  }



  Future<Response<dynamic>> _get(

    String path, {

    Map<String, dynamic>? query,

  }) async {

    try {

      return await _dio.get<dynamic>(

        path,

        queryParameters: query,

      );

    } on DioException catch (e) {

      throw _mapDio(e);

    }

  }



  Map<String, dynamic> _asMap(dynamic data) {

    if (data is Map<String, dynamic>) return data;

    if (data is Map) return Map<String, dynamic>.from(data);

    throw AnalyticsApiException(

      message: 'Unexpected analytics response shape.',

      kind: AnalyticsErrorKind.validation,

    );

  }



  AnalyticsApiException _mapDio(DioException e) {

    final code = e.response?.statusCode;

    final detail = _extractDetail(e.response?.data) ?? e.message;



    if (code == 403) {

      return AnalyticsApiException.forbidden(

        detail ?? "You don't have access to Analytics",

      );

    }

    if (code == 401) {

      return AnalyticsApiException.unauthorized(detail);

    }

    if (code == 400) {

      return AnalyticsApiException(

        message: detail ?? 'Invalid request.',

        statusCode: 400,

        kind: AnalyticsErrorKind.validation,

      );

    }

    if (e.type == DioExceptionType.connectionTimeout ||

        e.type == DioExceptionType.receiveTimeout ||

        e.type == DioExceptionType.connectionError) {

      return AnalyticsApiException.network(detail);

    }

    return AnalyticsApiException(

      message: detail ?? 'Unable to load analytics.',

      statusCode: code,

      kind: AnalyticsErrorKind.unknown,

    );

  }



  String? _extractDetail(dynamic data) {

    if (data is Map) {

      final d = data['detail'] ?? data['message'] ?? data['error'];

      if (d != null) return d.toString();

    }

    if (data is String && data.isNotEmpty) return data;

    return null;

  }

}


