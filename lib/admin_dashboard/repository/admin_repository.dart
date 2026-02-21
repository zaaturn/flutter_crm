import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';

import '../model/employee.dart';
import '../model/project.dart';
import '../model/events.dart';
import '../model/task.dart';
import '../model/user.dart';

import 'package:my_app/services/api_client.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/services/secure_storage_service.dart';
import 'package:my_app/services/notification_service.dart';

/* ================================
 * ADMIN PROFILE MODEL
 * ================================ */

class AdminProfile {
  final String username;
  final String role;

  AdminProfile({
    required this.username,
    required this.role,
  });

  factory AdminProfile.fromJson(Map<String, dynamic> json) {
    return AdminProfile(
      username: json['username'],
      role: json['role'],
    );
  }
}

/* ================================
 * ADMIN REPOSITORY
 * ================================ */

class AdminRepository {
  final ApiClient _api = ApiClient();
  final SecureStorageService _storage = SecureStorageService();
  final NotificationService _notification = NotificationService();


  static const String _base =
  String.fromEnvironment('BASE_URL', defaultValue: 'http://localhost:8000');

  String get _crmBase => "$_base/api/employee/crm/";
  String get _accountsBase => "$_base/api/accounts/crm/";
  String get _taskBase => "$_base/admin_panel/";
  String get _eventBase => "$_base/api/events/";

  // -------------------------------------------------
  // REGISTER ADMIN NOTIFICATION DEVICE
  // -------------------------------------------------
  Future<void> registerNotificationDevice() async {
    await _notification.registerDevice(owner: "ADMIN");
    _notification.listenForTokenRefresh(owner: "ADMIN");
  }

  // -------------------------------------------------
  // ADMIN PROFILE
  // -------------------------------------------------
  Future<AdminProfile> fetchProfile() async {
    final res = await _api.get("${_accountsBase}me/");
    return AdminProfile.fromJson(res);
  }

  // -------------------------------------------------
  // LIVE EMPLOYEES
  // -------------------------------------------------
  Future<List<Employee>> fetchLiveEmployees() async {
    final raw = await _api.getList("${_crmBase}live-status/");
    print("LIVE STATUS RAW: $raw");
    return raw
        .map((e) => Employee.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  // -------------------------------------------------
  // EMPLOYEES
  // -------------------------------------------------
  Future<List<User>> fetchEmployees() async {
    final res = await _api.get("${_accountsBase}employees/");
    final List<dynamic> results = res['results'];

    return results
        .map((e) => User.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  // -------------------------------------------------
  // PROJECTS
  // -------------------------------------------------
  Future<List<Project>> fetchProjects() async {
    final raw = await _api.getList("${_crmBase}projects/");
    return raw
        .map((e) => Project.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  // -------------------------------------------------
  // EVENTS
  // -------------------------------------------------
  Future<List<DashboardEvent>> fetchEvents() async {
    final token = await _storage.readToken();

    final response = await http.get(
      Uri.parse(_eventBase),
      headers: {
        "Content-Type": "application/json",
        if (token != null && token.isNotEmpty)
          "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);

      if (decoded is Map<String, dynamic> &&
          decoded.containsKey("results")) {
        final List<dynamic> results = decoded["results"];
        return results
            .map((e) =>
            DashboardEvent.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      if (decoded is List) {
        return decoded
            .map((e) =>
            DashboardEvent.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      return [];
    } else {
      throw Exception("API Error ${response.statusCode}");
    }
  }

  // -------------------------------------------------
  // CREATE TASK
  // -------------------------------------------------
  Future<void> createTask({
    required int assignedTo,
    required String title,
    required String description,
    required String priority,
    required String dueDate,
    PlatformFile? attachment,
  }) async {
    final token = await _storage.readToken();
    if (token == null || token.isEmpty) {
      throw Exception("User not authenticated");
    }

    final uri = Uri.parse("${_taskBase}tasks/create/");
    final request = http.MultipartRequest("POST", uri);

    request.headers["Authorization"] = "Bearer $token";

    request.fields.addAll({
      "assigned_to": assignedTo.toString(),
      "title": title,
      "description": description,
      "priority": priority.toUpperCase(),
      "due_date": dueDate,
    });

    if (attachment != null) {
      if (kIsWeb) {
        request.files.add(
          http.MultipartFile.fromBytes(
            "attachment",
            attachment.bytes!,
            filename: attachment.name,
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath(
            "attachment",
            attachment.path!,
          ),
        );
      }
    }

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode != 201) {
      throw Exception("API Error ${response.statusCode}: $body");
    }
  }

  // -------------------------------------------------
  // FETCH TASKS
  // -------------------------------------------------
  Future<List<Task>> fetchTasks() async {
    final raw = await _api.getList("${_crmBase}tasks/");
    return raw
        .map((e) => Task.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
