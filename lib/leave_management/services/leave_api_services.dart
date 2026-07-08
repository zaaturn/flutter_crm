import 'package:intl/intl.dart';
import 'package:my_app/services/api_client.dart';
import 'package:my_app/core/error_handler/error_handler.dart';

import '../models/leave_type.dart';
import '../models/leave_balance_response.dart';
import '../models/leave_request.dart';
import '../models/public_holiday.dart';
import '../models/approver.dart';
import '../models/leave_dashboard_model.dart';

class LeaveApiService {
  final ApiClient _api = ApiClient();

  // ===============================
  // COMMON SAFE EXECUTOR (FIXED)
  // ===============================
  Future<T> _safeRequest<T>(Future<T> Function() request) async {
    try {
      return await request();
    } catch (e) {
      // 🔥 Use your centralized error handler
      throw Exception(ErrorHandler.format(e));
    }
  }

  // ===============================
  // LEAVE TYPES
  // ===============================
  Future<List<LeaveType>> getLeaveTypes() async {
    return _safeRequest(() async {
      final data = await _api.get("/api/leaves/leave-types/");
      final results = data['results'] ?? data;

      return (results as List)
          .map((e) => LeaveType.fromJson(e))
          .toList();
    });
  }

  // ===============================
  // LEAVE BALANCES (GET /api/leaves/balances/)
  // ===============================
  Future<LeaveBalanceResponse> fetchMyLeaveBalances({int? year}) async {
    return _safeRequest(() async {
      final data = await _api.get(
        '/api/leaves/balances/',
        queryParameters: year != null ? {'year': year} : null,
      );
      return LeaveBalanceResponse.fromJson(Map<String, dynamic>.from(data));
    });
  }

  // ===============================
  // MY LEAVES
  // ===============================
  Future<List<LeaveRequest>> getMyLeaves({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return _safeRequest(() async {
      final params = <String, dynamic>{};

      if (status != null) params["status"] = status;
      if (startDate != null) {
        params["start_date"] = startDate.toIso8601String();
      }
      if (endDate != null) {
        params["end_date"] = endDate.toIso8601String();
      }

      final data = await _api.get(
        "/api/leaves/my-leaves/",
        queryParameters: params.isEmpty ? null : params,
      );

      final results = data['results'] ?? data;

      return (results as List)
          .map((e) => LeaveRequest.fromJson(e))
          .toList();
    });
  }

  /// GET `/api/leaves/my-leaves/{id}/` — detail for edit form.
  Future<LeaveRequest> getMyLeaveDetail(int id) async {
    try {
      final data = await _api.get('/api/leaves/my-leaves/$id/');
      final raw = data['leave'] ?? data;
      if (raw is! Map) {
        throw Exception('Invalid leave detail response');
      }
      return LeaveRequest.fromJson(Map<String, dynamic>.from(raw));
    } on ApiException catch (e) {
      throw Exception(_formatLeaveApiError(e));
    } catch (e) {
      throw Exception(ErrorHandler.format(e));
    }
  }

  static String _formatLeaveApiError(ApiException e) {
    if (e.code == 403) {
      return e.data is Map && (e.data as Map)['detail'] != null
          ? (e.data as Map)['detail'].toString()
          : "You can't edit this leave.";
    }
    if (e.code == 400 && e.data is Map<String, dynamic>) {
      return _drfFieldErrors(e.data as Map<String, dynamic>);
    }
    return e.message;
  }

  static String _drfFieldErrors(Map<String, dynamic> map) {
    final lines = <String>[];
    map.forEach((key, value) {
      if (value is List) {
        lines.add('$key: ${value.map((e) => e.toString()).join(', ')}');
      } else if (value is Map) {
        lines.add('$key: ${value.toString()}');
      } else {
        lines.add('$key: $value');
      }
    });
    return lines.isEmpty ? 'Validation failed.' : lines.join('\n');
  }

  // ===============================
  // ALL LEAVES
  // ===============================
  Future<List<LeaveRequest>> getAllLeaves() async {
    return _safeRequest(() async {
      final data = await _api.get("/api/leaves/all/");
      final results = data['results'] ?? data;

      return (results as List)
          .map((e) => LeaveRequest.fromJson(e))
          .toList();
    });
  }

  // ===============================
  // APPLY LEAVE
  // ===============================
  Future<void> applyLeave({
    required int leaveTypeId,
    required DateTime startDate,
    required DateTime endDate,
    String? reason,
    String duration = 'FULL',
  }) async {
    return _safeRequest(() async {
      await _api.post(
        "/api/leaves/apply/",
        body: {
          "leave_type": leaveTypeId,
          "start_date": DateFormat('yyyy-MM-dd').format(startDate),
          "end_date": DateFormat('yyyy-MM-dd').format(endDate),
          "duration": duration,
          "reason": reason,
        },
      );
    });
  }

  // ===============================
  // UPDATE LEAVE (PATCH — PENDING only on server)
  // ===============================
  /// Returns server [detail] message and optional parsed [leave] from `response['leave']`.
  Future<({String detail, LeaveRequest? leave})> updateLeave({
    required int leaveId,
    required int leaveTypeId,
    required DateTime startDate,
    required DateTime endDate,
    required String duration,
    required String reason,
  }) async {
    try {
      final body = <String, dynamic>{
        'leave_type': leaveTypeId,
        'start_date': DateFormat('yyyy-MM-dd').format(startDate),
        'end_date': DateFormat('yyyy-MM-dd').format(endDate),
        'duration': duration,
        'reason': reason,
      };

      final res = await _api.patch(
        '/api/leaves/update/$leaveId/',
        body: body,
      );

      final detail =
          res['detail']?.toString() ?? 'Leave updated successfully';
      LeaveRequest? leave;
      final rawLeave = res['leave'];
      if (rawLeave is Map) {
        leave = LeaveRequest.fromJson(Map<String, dynamic>.from(rawLeave));
      }

      return (detail: detail, leave: leave);
    } on ApiException catch (e) {
      throw Exception(_formatLeaveApiError(e));
    } catch (e) {
      throw Exception(ErrorHandler.format(e));
    }
  }

  // ===============================
  // DELETE LEAVE
  // ===============================
  Future<String> deleteLeave(int leaveId) async {
    return _safeRequest(() async {
      final res = await _api.delete("/api/leaves/delete/$leaveId/");
      return res['detail'] ?? "Leave deleted successfully";
    });
  }

  // ===============================
  // SEARCH ADMINS
  // ===============================
  Future<List<Approver>> searchAdmins(String query) async {
    return _safeRequest(() async {
      final data = await _api.get(
        "/api/leaves/admins/search/",
        queryParameters: {"q": query},
      );

      return (data as List)
          .map((e) => Approver.fromJson(e))
          .toList();
    });
  }

  // ===============================
  // PENDING LEAVES
  // ===============================
  Future<List<LeaveRequest>> getPendingLeaves() async {
    return _safeRequest(() async {
      final data = await _api.get("/api/leaves/pending/");
      final results = data['results'] ?? data;

      return (results as List)
          .map((e) => LeaveRequest.fromJson(e))
          .toList();
    });
  }

  // ===============================
  // ADMIN ACTIONS
  // ===============================
  Future<void> approveLeave(int leaveId, {String? comment}) async {
    return _safeRequest(() async {
      await _api.post(
        "/api/leaves/approve/$leaveId/",
        body: {"comment": comment},
      );
    });
  }

  Future<void> rejectLeave(int leaveId, {String? comment}) async {
    return _safeRequest(() async {
      await _api.post(
        "/api/leaves/reject/$leaveId/",
        body: {"comment": comment},
      );
    });
  }

  Future<void> cancelLeave(int leaveId) async {
    return _safeRequest(() async {
      await _api.post("/api/leaves/cancel/$leaveId/");
    });
  }

  // ===============================
  // PUBLIC HOLIDAYS
  // GET /api/leaves/holidays/?year=YYYY&month=MM (optional)
  // Response: { holidays: [...] } | { months: [...] } | { results: [...] }
  // ===============================
  Future<List<PublicHoliday>> getPublicHolidays(int year, {int? month}) async {
    return _safeRequest(() async {
      final params = <String, dynamic>{'year': year};
      if (month != null) params['month'] = month;

      final data = await _api.get(
        '/api/leaves/holidays/',
        queryParameters: params,
      );
      var holidays = parsePublicHolidayResponse(data);

      if (holidays.isEmpty && month != null) {
        final yearData = await _api.get(
          '/api/leaves/holidays/',
          queryParameters: {'year': year},
        );
        holidays = parsePublicHolidayResponse(yearData)
            .where((h) => h.date.month == month)
            .toList();
      }

      if (holidays.isEmpty && month == null) {
        holidays = await _fetchHolidaysMonthByMonth(year);
      }

      if (holidays.isEmpty) {
        holidays = await _fetchHolidaysFromEventsCalendar(year);
        if (month != null) {
          holidays =
              holidays.where((h) => h.date.month == month).toList();
        }
      }

      return holidays;
    });
  }

  Future<List<PublicHoliday>> _fetchHolidaysMonthByMonth(int year) async {
    final monthly = <List<PublicHoliday>>[];
    for (var m = 1; m <= 12; m++) {
      final data = await _api.get(
        '/api/leaves/holidays/',
        queryParameters: {'year': year, 'month': m},
      );
      final monthHolidays = parsePublicHolidayResponse(data);
      if (monthHolidays.isNotEmpty) {
        monthly.add(monthHolidays);
      }
    }
    return mergePublicHolidayLists(monthly);
  }

  Future<List<PublicHoliday>> _fetchHolidaysFromEventsCalendar(int year) async {
    final data = await _api.get(
      '/api/events/calendar/',
      queryParameters: {
        'start': '$year-01-01',
        'end': '$year-12-31',
        'include_tasks': false,
        'include_holidays': true,
      },
    );

    final raw = data['holidays'];
    if (raw is! List) return const [];

    final rows = raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    return parsePublicHolidayList(rows);
  }

  // ===============================
  // DASHBOARD
  // ===============================
  Future<LeaveDashboardModel> getDashboardCounts() async {
    return _safeRequest(() async {
      final data = await _api.get("/api/leaves/dashboard/");
      return LeaveDashboardModel.fromJson(data);
    });
  }
}