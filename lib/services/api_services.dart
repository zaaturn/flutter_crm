import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:cross_file/cross_file.dart';

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

  String get baseUrl => _api.baseEmployee;

  Future<Map<String, dynamic>> getProfile() async {
    return await _api.get("$baseUrl/profile/");
  }

  /// -------------------------------
  /// UPLOAD PROFILE PHOTO
  /// -------------------------------

  Future<Map<String, dynamic>> uploadProfilePhoto(XFile file) async {
    final token = await _storage.readToken();
    if (token == null || token.isEmpty) {
      throw ApiException(401, "User is logged out");
    }

    final request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/profile/upload-photo/"),
    );

    request.headers["Authorization"] = "Bearer $token";


    if (kIsWeb) {
      final bytes = await file.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          "profile_photo",
          bytes,
          filename: file.name,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    } else {
      // For Desktop and Mobile
      request.files.add(
        await http.MultipartFile.fromPath(
          "profile_photo",
          file.path,
        ),
      );
    }

    try {
      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode >= 200 && streamedResponse.statusCode < 300) {
        return jsonDecode(responseBody);
      }

      throw ApiException(streamedResponse.statusCode, responseBody);
    } catch (e) {
      throw Exception("Upload Error: $e");
    }
  }
}