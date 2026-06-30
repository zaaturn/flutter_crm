import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';

import '../model/live_attendance_snapshot.dart';
import '../model/pagenated_response.dart';
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

  Future<LiveAttendanceSnapshot> fetchLiveAttendance() async {
    try {
      final raw = await _api.getList("${_crmBase}live-status/");
      final rosterById = <int, Employee>{};
      var totalEmployees = 0;

      try {
        var page = 1;
        var hasMore = true;
        while (hasMore) {
          final res = await _api.get(
            "${_accountsBase}employeeslist/",
            queryParameters: {
              'page': page,
              'page_size': 100,
              'ordering': 'first_name',
            },
          );
          final parsed = PaginatedResponse.fromJson(res);
          if (page == 1) totalEmployees = parsed.count;
          for (final employee in parsed.results) {
            rosterById[employee.id] = employee;
          }
          hasMore = parsed.hasMore;
          page++;
          if (page > 100) break;
        }
      } catch (_) {
        totalEmployees = await _fetchTotalEmployeeCount();
      }

      if (totalEmployees == 0) {
        totalEmployees = await _fetchTotalEmployeeCount();
      }

      final todayLoggedIn = _buildTodayLoggedIn(raw, rosterById);

      return LiveAttendanceSnapshot(
        totalEmployees: totalEmployees,
        todayLoggedIn: todayLoggedIn,
      );
    } catch (e) {
      throw Exception(ErrorHandler.format(e));
    }
  }

  Future<List<Employee>> fetchLiveEmployees() async {
    final snapshot = await fetchLiveAttendance();
    return snapshot.todayLoggedIn;
  }

  Future<int> _fetchTotalEmployeeCount() async {
    try {
      final res = await _api.get(
        "${_accountsBase}employeeslist/",
        queryParameters: {'page': 1, 'page_size': 1},
      );
      return PaginatedResponse.fromJson(res).count;
    } catch (_) {
      return 0;
    }
  }

  List<Employee> _buildTodayLoggedIn(
    List<dynamic> raw,
    Map<int, Employee> rosterById,
  ) {
    final todayLoggedIn = <Employee>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final live = Map<String, dynamic>.from(item);
      final id = _parseEmployeeId(live['id']);
      if (id == null) continue;

      final rosterEmployee = rosterById[id];
      if (rosterEmployee != null) {
        todayLoggedIn.add(_mergeEmployeeLiveStatus(rosterEmployee, live));
      } else {
        todayLoggedIn.add(Employee.fromJson(live));
      }
    }
    return todayLoggedIn;
  }

  Future<List<Employee>> _fetchAllEmployeesFromList() async {
    final all = <Employee>[];
    var page = 1;
    var hasMore = true;

    while (hasMore) {
      final res = await _api.get(
        "${_accountsBase}employeeslist/",
        queryParameters: {
          'page': page,
          'page_size': 100,
          'ordering': 'first_name',
        },
      );
      final parsed = PaginatedResponse.fromJson(res);
      all.addAll(parsed.results);
      hasMore = parsed.hasMore;
      page++;
      if (page > 100) break;
    }

    return all;
  }

  int? _parseEmployeeId(dynamic id) {
    if (id is int) return id;
    if (id == null) return null;
    return int.tryParse(id.toString());
  }

  Employee _mergeEmployeeLiveStatus(
    Employee employee,
    Map<String, dynamic>? live,
  ) {
    if (live == null) {
      return employee.copyWith(liveStatus: LiveStatus.loggedOut);
    }

    final liveName = live['name']?.toString().trim();
    final resolvedName = (liveName != null && liveName.isNotEmpty)
        ? liveName
        : (employee.name.trim().isNotEmpty
            ? employee.name
            : employee.fullName);

    return Employee.fromJson({
      'id': employee.id,
      'name': resolvedName,
      'first_name': employee.firstName,
      'last_name': employee.lastName,
      'email': employee.email,
      'employee_id': employee.employeeId,
      'username': employee.username,
      'phone_number': employee.phoneNumber,
      'designation': live['designation'] ?? employee.designation,
      'department': live['department'] ?? employee.department,
      'work_location': live['work_location'] ?? employee.workLocation,
      'address': employee.address,
      'date_of_birth': employee.dateOfBirth,
      'date_of_joining': employee.dateOfJoining,
      'is_active': employee.isActive,
      'profile_photo': employee.profilePhoto,
      'status': live['status'],
      'on_break': live['on_break'] ?? live['is_on_break'] ?? live['is_break'],
      'check_in': live['check_in'],
      'check_out': live['check_out'],
    });
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
      final data = await _api.get('${_eventBase}today/');

      final results = data is List ? data : (data['results'] ?? []);

      if (results is List) {
        return results
            .map((e) => DashboardEvent.tryFromJson(
                  Map<String, dynamic>.from(e as Map),
                ))
            .whereType<DashboardEvent>()
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