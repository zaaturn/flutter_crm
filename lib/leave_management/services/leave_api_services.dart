import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:my_app/services/secure_storage_service.dart';

import '../models/leave_type.dart';
import '../models/leave_balance.dart';
import '../models/leave_request.dart';
import '../models/public_holiday.dart';
import '../models/approver.dart';

class LeaveApiService {
  final SecureStorageService _storage = SecureStorageService();


  static const String _base =
  String.fromEnvironment('BASE_URL', defaultValue: 'http://localhost:8000');

  static String get baseUrl => "$_base/api";

  // ===============================
  // HEADERS
  // ===============================
  Future<Map<String, String>> _headers() async {
    final token = await _storage.readToken();
    if (token == null || token.isEmpty) {
      throw Exception("User not authenticated");
    }

    return {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };
  }

  // ===============================
  // RESPONSE HANDLER
  // ===============================
  dynamic _handleResponse(http.Response response, String endpoint) {
    debugPrint('📡 API Response [$endpoint]: ${response.statusCode}');
    debugPrint('📦 Response Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }

    debugPrint('❌ API Error: ${response.statusCode} - ${response.body}');
    throw Exception("API error ${response.statusCode} at $endpoint");
  }

  List _extractResults(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('results')) {
      return data['results'];
    }
    if (data is List) return data;
    return [];
  }

  // ===============================
  // LEAVE TYPES
  // ===============================
  Future<List<LeaveType>> getLeaveTypes() async {
    final res = await http.get(
      Uri.parse("$baseUrl/leaves/leave-types/"),
      headers: await _headers(),
    );

    final data = _handleResponse(res, "/leave-types/");
    return _extractResults(data)
        .map((e) => LeaveType.fromJson(e))
        .toList();
  }

  // ===============================
  // LEAVE BALANCES
  // ===============================
  Future<List<LeaveBalance>> getMyLeaveBalances() async {
    final res = await http.get(
      Uri.parse("$baseUrl/leaves/my-balances/"),
      headers: await _headers(),
    );

    final data = _handleResponse(res, "/my-balances/");
    return _extractResults(data)
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
    final params = <String, String>{};

    if (status != null) params["status"] = status;
    if (startDate != null) {
      params["start_date"] = startDate.toIso8601String();
    }
    if (endDate != null) {
      params["end_date"] = endDate.toIso8601String();
    }

    final uri = Uri.parse("$baseUrl/leaves/my-leaves/")
        .replace(queryParameters: params.isEmpty ? null : params);

    final res = await http.get(uri, headers: await _headers());
    final data = _handleResponse(res, "/my-leaves/");

    return _extractResults(data)
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
    required int approverId,
    String? reason,
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/leaves/apply/"),
      headers: await _headers(),
      body: jsonEncode({
        "leave_type": leaveTypeId,
        "start_date": startDate.toIso8601String().split('T')[0],
        "end_date": endDate.toIso8601String().split('T')[0],
        "reason": reason,
        "approver": approverId,
      }),
    );
    print("BODY BEING SENT:");


    _handleResponse(res, "/leaves/apply/");
  }

  // ===============================
  // SEARCH ADMINS
  // ===============================
  Future<List<Approver>> searchAdmins(String query) async {
    final res = await http.get(
      Uri.parse("$baseUrl/leaves/admins/search/?q=$query"),
      headers: await _headers(),
    );

    final data = _handleResponse(res, "/admins/search/");
    return (data as List)
        .map((e) => Approver.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ===============================
  // PENDING LEAVES (ADMIN)
  // ===============================
  Future<List<LeaveRequest>> getPendingLeaves() async {
    final res = await http.get(
      Uri.parse("$baseUrl/leaves/pending/"),
      headers: await _headers(),
    );

    final data = _handleResponse(res, "/pending/");
    return _extractResults(data)
        .map((e) => LeaveRequest.fromJson(e))
        .toList();
  }

  // ===============================
  // ADMIN ACTIONS
  // ===============================
  Future<void> approveLeave(int leaveId, {String? comment}) async {
    final res = await http.post(
      Uri.parse("$baseUrl/leaves/approve/$leaveId/"),
      headers: await _headers(),
      body: jsonEncode({"comment": comment}),
    );

    _handleResponse(res, "/approve/$leaveId/");
  }

  Future<void> rejectLeave(int leaveId, {String? comment}) async {
    final res = await http.post(
      Uri.parse("$baseUrl/leaves/reject/$leaveId/"),
      headers: await _headers(),
      body: jsonEncode({"comment": comment}),
    );

    _handleResponse(res, "/reject/$leaveId/");
  }

  Future<void> cancelLeave(int leaveId) async {
    final res = await http.post(
      Uri.parse("$baseUrl/leaves/cancel/$leaveId/"),
      headers: await _headers(),
    );

    _handleResponse(res, "/cancel/$leaveId/");
  }

  // ===============================
  // PUBLIC HOLIDAYS
  // ===============================
  Future<List<PublicHoliday>> getPublicHolidays(int year) async {
    final res = await http.get(
      Uri.parse("$baseUrl/leaves/holidays/?year=$year"),
      headers: await _headers(),
    );

    final data = _handleResponse(res, "/holidays/");
    return _extractResults(data)
        .map((e) => PublicHoliday.fromJson(e))
        .toList();
  }
}
