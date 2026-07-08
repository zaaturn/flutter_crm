import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:cross_file/cross_file.dart';

import '../model/attendance_model.dart';
import '../model/weekly_activity_model.dart';
import 'package:my_app/analytics/utils/iso_week.dart';
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
    return _profileService.fetchMyProfile();
  }

  Future<EmployeeModel> updateEmployeeProfile(Map<String, dynamic> body) async {
    return _profileService.updateMyProfile(body);
  }

  Future<String> uploadProfilePhoto(XFile file) async {
    return _profileService.uploadProfilePhoto(file);
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

  Future<WeeklyActivityModel> fetchWeeklyActivity() async {
    final iso = IsoWeek.current();
    final emptyWeek = WeeklyActivityModel.forIsoWeek(iso.year, iso.week);
    try {
      final data = await _attendanceService.getWeeklyActivity(
        year: iso.year,
        week: iso.week,
      );
      return WeeklyActivityModel.fromJson(
        Map<String, dynamic>.from(data),
        year: iso.year,
        week: iso.week,
      );
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('fetchWeeklyActivity failed: $e\n$st');
      }
      return emptyWeek;
    }
  }

  Future<AttendanceModel> toggleCheckIn() async {
    try {
      final today = await _attendanceService.getTodayStatus();
      final a = AttendanceModel.fromMap(Map<String, dynamic>.from(today));
      final bool isCheckedIn = a.isCheckedIn;

      if (!isCheckedIn) {
        final data = await _attendanceService.checkIn();
        if (data.isNotEmpty) {
          final m = Map<String, dynamic>.from(data);
          // If payload is partial, re-sync from server truth.
          final hasNet =
              m.containsKey('net_work_seconds') || m.containsKey('net_work_minutes');
          final hasBreak = m.containsKey('total_break_seconds') ||
              m.containsKey('total_break_minutes');
          if (hasNet || hasBreak || m.containsKey('is_checked_in')) {
            return AttendanceModel.fromMap(m);
          }
        }
      } else {
        final data = await _attendanceService.checkOut();
        if (data.isNotEmpty) {
          final m = Map<String, dynamic>.from(data);
          final hasNet =
              m.containsKey('net_work_seconds') || m.containsKey('net_work_minutes');
          final hasBreak = m.containsKey('total_break_seconds') ||
              m.containsKey('total_break_minutes');
          if (hasNet || hasBreak || m.containsKey('is_checked_in')) {
            return AttendanceModel.fromMap(m);
          }
        }
      }

      final updated = await _attendanceService.getTodayStatus();
      return AttendanceModel.fromMap(
        Map<String, dynamic>.from(updated),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<AttendanceModel> toggleBreak() async {
    final today = await _attendanceService.getTodayStatus();
    final a = AttendanceModel.fromMap(Map<String, dynamic>.from(today));
    final bool onBreak = a.onBreak;

    if (!onBreak) {
      final data = await _attendanceService.startBreak();
      if (data.isNotEmpty) {
        final m = Map<String, dynamic>.from(data);
        final hasNet =
            m.containsKey('net_work_seconds') || m.containsKey('net_work_minutes');
        final hasBreak = m.containsKey('total_break_seconds') ||
            m.containsKey('total_break_minutes');
        final hasState = m.containsKey('on_break') || m.containsKey('is_checked_in');
        // If the break endpoint doesn't return full attendance payload,
        // do not let the UI regress to zeros—re-sync from today/ instead.
        if (hasNet && hasBreak && hasState) {
          return AttendanceModel.fromMap(m);
        }
      }
    } else {
      final data = await _attendanceService.endBreak();
      if (data.isNotEmpty) {
        final m = Map<String, dynamic>.from(data);
        final hasNet =
            m.containsKey('net_work_seconds') || m.containsKey('net_work_minutes');
        final hasBreak = m.containsKey('total_break_seconds') ||
            m.containsKey('total_break_minutes');
        final hasState = m.containsKey('on_break') || m.containsKey('is_checked_in');
        if (hasNet && hasBreak && hasState) {
          return AttendanceModel.fromMap(m);
        }
      }
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
  //  NOTIFICATIONS (WEB + mobile)
  // ----------------------------

  Future<String?> getFcmToken() async {
    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission();

    return await messaging.getToken(
      vapidKey: kIsWeb ? "BDl2RpvxVJ442k-TJpCoAFHH3SLFxClV7Zy71uNq_MfRJPWTzi5qRkCPztfD2sIq--7LHESRCHbIVZO1ACehWhM" : null,
    );
  }

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
