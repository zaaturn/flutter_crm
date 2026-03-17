import 'package:my_app/services/api_client.dart';

import '../models/leave_type.dart';
import '../models/leave_balance.dart';
import '../models/leave_request.dart';
import '../models/public_holiday.dart';
import '../models/approver.dart';

class LeaveApiService {
  final ApiClient _api = ApiClient();

  // ===============================
  // LEAVE TYPES
  // ===============================
  Future<List<LeaveType>> getLeaveTypes() async {
    final data = await _api.get("/api/leaves/leave-types/");
    final results = data['results'] ?? data;

    return (results as List)
        .map((e) => LeaveType.fromJson(e))
        .toList();
  }

  // ===============================
  // LEAVE BALANCES
  // ===============================
  Future<List<LeaveBalance>> getMyLeaveBalances() async {
    final data = await _api.get("/api/leaves/my-balances/");
    final results = data['results'] ?? data;

    return (results as List)
        .map((e) => LeaveBalance.fromJson(e))
        .toList();
  }

  // ===============================
  // MY LEAVES
  // ===============================
  Future<List<LeaveRequest>> getMyLeaves({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
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
  }

  // ===============================
  // APPLY LEAVE
  // ===============================
  Future<void> applyLeave({
    required int leaveTypeId,
    required DateTime startDate,
    required DateTime endDate,
    String? reason,
  }) async {
    await _api.post(
      "/api/leaves/apply/",
      body: {
        "leave_type": leaveTypeId,
        "start_date": startDate.toIso8601String().split('T')[0],
        "end_date": endDate.toIso8601String().split('T')[0],
        "reason": reason,
      },
    );
  }

  // ===============================
  // SEARCH ADMINS
  // ===============================
  Future<List<Approver>> searchAdmins(String query) async {
    final data = await _api.get(
      "/api/leaves/admins/search/",
      queryParameters: {"q": query},
    );

    return (data as List)
        .map((e) => Approver.fromJson(e))
        .toList();
  }

  // ===============================
  // PENDING LEAVES (ADMIN)
  // ===============================
  Future<List<LeaveRequest>> getPendingLeaves() async {
    final data = await _api.get("/api/leaves/pending/");
    final results = data['results'] ?? data;

    return (results as List)
        .map((e) => LeaveRequest.fromJson(e))
        .toList();
  }

  // ===============================
  // ADMIN ACTIONS
  // ===============================
  Future<void> approveLeave(int leaveId, {String? comment}) async {
    await _api.post(
      "/api/leaves/approve/$leaveId/",
      body: {"comment": comment},
    );
  }

  Future<void> rejectLeave(int leaveId, {String? comment}) async {
    await _api.post(
      "/api/leaves/reject/$leaveId/",
      body: {"comment": comment},
    );
  }

  Future<void> cancelLeave(int leaveId) async {
    await _api.post(
      "/api/leaves/cancel/$leaveId/",
    );
  }

  // ===============================
  // PUBLIC HOLIDAYS
  // ===============================
  Future<List<PublicHoliday>> getPublicHolidays(int year) async {
    final data = await _api.get(
      "/api/leaves/holidays/",
      queryParameters: {"year": year},
    );

    final results = data['results'] ?? data;

    return (results as List)
        .map((e) => PublicHoliday.fromJson(e))
        .toList();
  }
}