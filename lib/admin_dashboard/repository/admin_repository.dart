import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';

import '../model/employee.dart';
import '../model/project.dart';
import '../model/events.dart';
import '../model/task.dart';
import '../model/user.dart';

import 'package:my_app/auth/auth_session.dart';
import 'package:my_app/services/api_client.dart';
import 'package:my_app/services/notification_service.dart';
import 'package:my_app/services/secure_storage_service.dart';
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

  /// Task assignee directory: admins + employees (`GET .../employeeslist/`).
  Future<List<User>> fetchEmployees() async {
    try {
      final List<User> allUsers = [];
      String? pageUrl = "${_accountsBase}employeeslist/";

      while (pageUrl != null) {
        final res = await _api.get(pageUrl);
        final results = res['results'];
        if (results is List) {
          for (final e in results) {
            if (e is Map) {
              allUsers.add(User.fromJson(Map<String, dynamic>.from(e)));
            }
          }
        }
        final next = res['next'];
        pageUrl =
            (next == null || next.toString().isEmpty) ? null : next.toString();
      }

      if (allUsers.isNotEmpty) return allUsers;

      final raw = await _api.getList("${_accountsBase}employeeslist/");
      return raw
          .map((e) => User.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      throw Exception(ErrorHandler.format(e));
    }
  }

  Future<bool> _isSuperuserFlag() async {
    final storage = SecureStorageService();
    if (await storage.readIsSuperuser()) return true;
    final raw = await storage.readAuthSessionJson();
    final session = AuthSession.fromStorageString(raw);
    return session?.isSuperuser ?? false;
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

  /// Superadmin board: `?all_pending=1`. Normal admin: `?outgoing=1`.
  /// On 403 for global queue, falls back to outgoing list.
  Future<List<Task>> fetchTasks() async {
    final isSuper = await _isSuperuserFlag();
    final primary = isSuper
        ? <String, dynamic>{'all_pending': 1}
        : <String, dynamic>{'outgoing': 1};

    try {
      final raw = await _api.getList(
        "${_crmBase}tasks/",
        queryParameters: primary,
      );
      return raw.map((e) => Task.fromJson(Map<String, dynamic>.from(e))).toList();
    } on ApiException catch (e) {
      if (e.code == 403 && isSuper) {
        final raw = await _api.getList(
          "${_crmBase}tasks/",
          queryParameters: const {'outgoing': 1},
        );
        return raw.map((t) => Task.fromJson(Map<String, dynamic>.from(t))).toList();
      }
      throw Exception(ErrorHandler.format(e));
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