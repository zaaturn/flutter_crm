import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../model/attendance_model.dart';
import '../model/task_model.dart';
import '../model/shared_item_model.dart';
import '../model/event_model.dart';
import '../model/employee_model.dart';

import 'package:my_app/services/api_services.dart'
    show AttendanceService, ProfileService, TaskService;

import 'package:my_app/services/auth_service.dart';
import 'package:my_app/services/notification_service.dart';

class EmployeeRepository {
  // ----------------------------
  // SERVICES
  // ----------------------------
  final AttendanceService _attendanceService = AttendanceService();
  final ProfileService _profileService = ProfileService();
  final TaskService _taskService = TaskService();
  final NotificationService _notificationService = NotificationService();
  final AuthService _authService = AuthService();

  // ----------------------------
  // EMPLOYEE PROFILE
  // ----------------------------
  Future<EmployeeModel> fetchEmployeeProfile() async {
    final data = await _profileService.getProfile();
    return EmployeeModel.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  // ----------------------------
  // ATTENDANCE
  // ----------------------------
  Future<AttendanceModel> fetchAttendance() async {
    final data = await _attendanceService.getTodayStatus();
    return AttendanceModel.fromMap(
      Map<String, dynamic>.from(data),
    );
  }

  Future<AttendanceModel> toggleCheckIn() async {
    final today = await _attendanceService.getTodayStatus();
    final bool isCheckedIn = today['is_checked_in'] ?? false;

    if (!isCheckedIn) {
      await _attendanceService.checkIn();
    } else {
      await _attendanceService.checkOut();
    }

    final updated = await _attendanceService.getTodayStatus();
    return AttendanceModel.fromMap(
      Map<String, dynamic>.from(updated),
    );
  }

  Future<AttendanceModel> toggleBreak() async {
    final today = await _attendanceService.getTodayStatus();
    final bool onBreak = today['on_break'] ?? false;

    if (!onBreak) {
      await _attendanceService.startBreak();
    } else {
      await _attendanceService.endBreak();
    }

    final updated = await _attendanceService.getTodayStatus();
    return AttendanceModel.fromMap(
      Map<String, dynamic>.from(updated),
    );
  }

  // ----------------------------
  // TASKS
  // ----------------------------
  Future<List<TaskModel>> fetchTasks() async {
    final data = await _taskService.getTasks();
    return data
        .map<TaskModel>(
          (e) => TaskModel.fromJson(
        Map<String, dynamic>.from(e),
      ),
    )
        .toList();
  }

  Future<void> updateTaskStatus(int taskId, String status) async {
    await _taskService.updateTaskStatus(taskId, status);
  }

  // ----------------------------
  //  NOTIFICATIONS (WEB + MOBILE)
  // ----------------------------

  /// Get FCM token for web or mobile
  Future<String?> getFcmToken() async {
    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission();

    return await messaging.getToken(
      vapidKey: kIsWeb ? "YOUR_WEB_VAPID_KEY" : null,
    );
  }

  /// Send token to backend so admin can push notifications
  Future<void> registerDeviceToken() async {
    await _notificationService.registerDevice(
      owner: "EMPLOYEE",
    );
  }

  // ----------------------------
  // SHARED ITEMS (TEMP / MOCK)
  // ----------------------------
  Future<List<SharedItemModel>> fetchSharedItems() async {
    return [
      SharedItemModel(
        id: 's1',
        title: 'Policy Update',
        description: 'Updated work from home policy.',
        sharedBy: 'Admin',
        sharedAt: DateTime.now(),
      ),
    ];
  }

  // ----------------------------
  // EVENTS (TEMP / MOCK)
  // ----------------------------
  Future<List<EventModel>> fetchEvents() async {
    return [
      EventModel(
        id: 'e1',
        title: 'Team Meeting',
        date: '2025-10-25',
        time: '10:00 AM',
        location: 'Conference Room',
      ),
    ];
  }

  // ----------------------------
  // LOGOUT (DESKTOP SAFE)
  // ----------------------------
  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (_) {}
  }
}
