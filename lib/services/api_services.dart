import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_client.dart';
import 'secure_storage_service.dart';

/* ================================
 * ATTENDANCE SERVICE
 * ================================ */

class AttendanceService {
  final SecureStorageService _storage = SecureStorageService();
  final ApiClient _api = ApiClient();

  String get _base => _api.baseEmployee;

  Future<Map<String, dynamic>> getTodayStatus() async {
    return await _api.get("$_base/attendance/today/");
  }

  Future<void> checkIn() async {
    final userId = await _storage.readUserId();
    if (userId == null) return;

    await _api.post(
      "$_base/attendance/check-in/",
      body: {"user_id": userId},
    );
  }

  Future<void> checkOut() async {
    final userId = await _storage.readUserId();
    if (userId == null) return;

    await _api.post(
      "$_base/attendance/check-out/",
      body: {"user_id": userId},
    );
  }

  Future<void> startBreak() async {
    final userId = await _storage.readUserId();
    if (userId == null) return;

    await _api.post(
      "$_base/attendance/break/start/",
      body: {"user_id": userId},
    );
  }

  Future<void> endBreak() async {
    final userId = await _storage.readUserId();
    if (userId == null) return;

    await _api.post(
      "$_base/attendance/break/end/",
      body: {"user_id": userId},
    );
  }
}

/* ================================
 * TASK SERVICE
 * ================================ */

class TaskService {
  final ApiClient _api = ApiClient();
  String get _base => _api.baseEmployee;

  Future<List<dynamic>> getTasks() async {
    final response = await _api.getList("$_base/tasks/");
    return response;
  }

  Future<void> updateTaskStatus(int taskId, String status) async {
    await _api.post(
      "$_base/tasks/$taskId/status/",
      body: {"status": status},
    );
  }
}

/* ================================
 * PROFILE SERVICE
 * ================================ */

class ProfileService {
  final ApiClient _api = ApiClient();
  final SecureStorageService _storage = SecureStorageService();

  String get _base => _api.baseEmployee;

  Future<Map<String, dynamic>> getProfile() async {
    return await _api.get("$_base/profile/");
  }

  /// -------------------------------
  /// UPLOAD PROFILE PHOTO
  /// -------------------------------

  Future<Map<String, dynamic>> uploadProfilePhoto(String filePath) async {
    if (kIsWeb) {
      throw UnsupportedError(
        "File upload via path is not supported on Web. "
            "Use bytes upload instead.",
      );
    }

    final token = await _storage.readToken();
    if (token == null || token.isEmpty) {
      throw ApiException(401, "User is logged out");
    }

    final request = http.MultipartRequest(
      "POST",
      Uri.parse("$_base/profile/upload-photo/"),
    );

    request.headers["Authorization"] = "Bearer $token";

    request.files.add(
      await http.MultipartFile.fromPath(
        "profile_photo",
        filePath,
      ),
    );

    final streamedResponse = await request.send();
    final responseBody =
    await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode >= 200 &&
        streamedResponse.statusCode < 300) {
      return jsonDecode(responseBody);
    }

    throw ApiException(
      streamedResponse.statusCode,
      responseBody,
    );
  }
}
