import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';

import '../model/employee.dart';
import '../model/project.dart';
import '../model/events.dart';
import '../model/task.dart';
import '../model/user.dart';

import 'package:my_app/services/api_client.dart';
import 'package:my_app/services/notification_service.dart';
import 'package:my_app/core/error_handler/error_handler.dart';

class AdminProfile {
  final String username;
  final String role;

  AdminProfile({
    required this.username,
    required this.role,
  });

  factory AdminProfile.fromJson(Map<String, dynamic> json) {
    return AdminProfile(
      username: json['username']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
    );
  }
}

class AdminRepository {
  final ApiClient _api = ApiClient();
  final NotificationService _notification = NotificationService();

  static const String _base =
  String.fromEnvironment('BASE_URL', defaultValue: 'http://192.168.1.13:8000');

  String get _crmBase => "$_base/api/employee/crm/";
  String get _accountsBase => "$_base/api/accounts/crm/";
  String get _taskBase => "$_base/admin_panel/";
  String get _eventBase => "$_base/api/events/";

  Future<void> registerNotificationDevice() async {
    await _notification.registerDevice(owner: "ADMIN");
    _notification.listenForTokenRefresh(owner: "ADMIN");
  }

  Future<AdminProfile> fetchProfile() async {
    try {
      final res = await _api.get("${_accountsBase}me/");
      return AdminProfile.fromJson(res);
    } catch (e) {
      throw Exception(ErrorHandler.format(e));
    }
  }

  Future<List<Employee>> fetchLiveEmployees() async {
    try {
      final raw = await _api.getList("${_crmBase}live-status/");
      return raw
          .map((e) => Employee.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      throw Exception(ErrorHandler.format(e));
    }
  }

  Future<List<User>> fetchEmployees() async {
    try {
      List<User> allUsers = [];
      String? url = "${_accountsBase}employees/";

      while (url != null) {
        final res = await _api.get(url);
        final List<dynamic> results = res['results'];
        allUsers.addAll(
          results.map((e) => User.fromJson(Map<String, dynamic>.from(e))).toList(),
        );
        url = res['next'];
      }

      return allUsers;
    } catch (e) {
      throw Exception(ErrorHandler.format(e));
    }
  }

  Future<List<Project>> fetchProjects() async {
    try {
      final raw = await _api.getList("${_crmBase}projects/");
      return raw
          .map((e) => Project.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      throw Exception(ErrorHandler.format(e));
    }
  }

  Future<List<DashboardEvent>> fetchEvents() async {
    try {
      final data = await _api.get(_eventBase);

      final results = data['results'] ?? data;

      if (results is List) {
        return results
            .map((e) =>
            DashboardEvent.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      return [];
    } catch (e) {
      throw Exception(ErrorHandler.format(e));
    }
  }

  Future<void> createTask({
    required int assignedTo,
    required String title,
    required String description,
    required String priority,
    required String dueDate,
    PlatformFile? attachment,
  }) async {
    try {
      final formData = FormData.fromMap({
        "assigned_to": assignedTo,
        "title": title,
        "description": description,
        "priority": priority.toUpperCase(),
        "due_date": dueDate,
        if (attachment != null && attachment.path != null)
          "attachment": await MultipartFile.fromFile(
            attachment.path!,
            filename: attachment.name,
          ),
      });

      await _api.post("${_taskBase}tasks/create/", body: formData);
    } catch (e) {
      throw Exception(ErrorHandler.format(e));
    }
  }

  Future<List<Task>> fetchTasks() async {
    try {
      final raw = await _api.getList("${_crmBase}tasks/");
      return raw.map((e) => Task.fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (e) {
      throw Exception(ErrorHandler.format(e));
    }
  }


  Future<void> approveTask(int taskId) async {
    try {
      await _api.post("${_crmBase}tasks/approve/$taskId/");
    } catch (e) {
      throw Exception(ErrorHandler.format(e));
    }
  }
}