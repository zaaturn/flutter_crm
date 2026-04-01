import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_app/services/secure_storage_service.dart';

import 'package:my_app/employee_dashboard/bloc/employee_dashboard_bloc.dart';
import 'package:my_app/employee_dashboard/screen/employee_task_tracker_screen.dart';
import 'package:my_app/employee_dashboard/widget/employee_task_tracker_screen_mobile.dart';
import 'package:my_app/dashboards/presentations/screens/post_detail_screen.dart';
import 'package:my_app/event_management/features/events/presentation/screens/event_detail_screen.dart';
import 'package:my_app/leave_management/block/leave_bloc.dart';
import 'package:my_app/leave_management/block/leave_event.dart';
import 'package:my_app/leave_management/block/leave_dashboard_bloc.dart';
import 'package:my_app/leave_management/block/leave_dashboard_event.dart';
import 'package:my_app/leave_management/services/leave_api_services.dart';
import 'package:my_app/leave_management/screens/employee_leave_status_screen.dart';

import 'package:my_app/admin_dashboard/screen/device_specific/track_task_desktop.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/track_task_screen_mobile.dart';
import 'package:my_app/leave_management/screens/device_specific/admin_leave_approve_panel.dart';

/// Normalizes FCM / local notification payload and navigates (task, event, leave).
abstract final class NotificationPayloadRouter {
  static String? _str(Map<String, dynamic> data, String key) {
    final v = data[key];
    if (v == null) return null;
    final s = v.toString();
    return s.isEmpty ? null : s;
  }

  /// [type] from `notif_type` or `type`.
  static String? resolvedType(Map<String, dynamic> data) {
    final t = _str(data, 'notif_type') ?? _str(data, 'type');
    return t?.trim().isEmpty == true ? null : t?.trim();
  }

  /// Parses JSON string payloads (some channels deliver nested JSON).
  static Map<String, dynamic> normalizeRaw(Object? raw) {
    if (raw == null) return {};
    if (raw is Map<String, dynamic>) return Map<String, dynamic>.from(raw);
    if (raw is Map) {
      return raw.map((k, v) => MapEntry(k.toString(), v));
    }
    if (raw is String) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) {
          return decoded.map((k, v) => MapEntry(k.toString(), v));
        }
      } catch (_) {}
    }
    return {};
  }

  static bool _isTaskType(String? type) {
    if (type == null) return false;
    return type == 'task_assigned' ||
        type == 'task_completed' ||
        type == 'task_approved';
  }

  static bool _isEventType(String? type) {
    if (type == null) return false;
    return type.contains('event') ||
        type == 'invite' ||
        type == 'reminder';
  }

  static void handle(
    Map<String, dynamic> data,
    GlobalKey<NavigatorState> navigatorKey,
  ) {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return;
    // Fire-and-forget: routing may need async role lookup.
    handleWithContext(ctx, data);
  }

  /// In-app notification list taps (already have a valid [BuildContext]).
  static void handleWithContext(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    // This method stays sync for call sites, but internally we can async.
    // ignore: discarded_futures
    _handleAsync(context, data);
  }

  static Future<void> _handleAsync(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    final type = resolvedType(data);
    final leaveId = _str(data, 'leave_id');
    final taskIdStr = _str(data, 'task_id');
    final eventId = _str(data, 'event_id');
    final postIdStr = _str(data, 'post_id');

    final role = await SecureStorageService().readRole();
    if (!context.mounted) return;
    final isAdmin = (role ?? '').toLowerCase() == 'admin';

    final postId = int.tryParse(postIdStr ?? '');
    if (postId != null) {
      _openPost(context, postId);
      return;
    }

    if (leaveId != null) {
      if (isAdmin) {
        _openLeaveAdmin(context, focusLeaveId: leaveId);
      } else {
        _openLeaveEmployee(context, leaveId);
      }
      return;
    }

    if (_isTaskType(type)) {
      final taskId = int.tryParse(taskIdStr ?? '');
      if (taskId != null) {
        if (isAdmin) {
          _openTasksAdmin(context);
        } else {
          _openTasksEmployee(context, focusTaskId: taskId);
        }
      }
      return;
    }

    if (eventId != null && (_isEventType(type) || type == 'invite')) {
      _openEvent(context, eventId);
      return;
    }

    if (eventId != null) {
      _openEvent(context, eventId);
      return;
    }

    final fallbackTask = int.tryParse(taskIdStr ?? '');
    if (fallbackTask != null) {
      if (isAdmin) {
        _openTasksAdmin(context);
      } else {
        _openTasksEmployee(context, focusTaskId: fallbackTask);
      }
    }
  }

  static void _openPost(BuildContext context, int postId) {
    Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => PostDetailScreen(postId: postId),
      ),
    );
  }

  static void _openEvent(BuildContext context, String eventId) {
    Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => EventDetailScreen(eventId: eventId),
      ),
    );
  }

  static void _openTasksEmployee(BuildContext context, {required int focusTaskId}) {
    final EmployeeBloc? bloc = _tryReadEmployeeBloc(context);
    if (bloc == null) {
      Navigator.of(context, rootNavigator: true).pushNamed('/employeeDashboard');
      return;
    }

    final wide = MediaQuery.sizeOf(context).width >= 900;
    Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: wide
              ? EmployeeTaskTrackerScreen(focusTaskId: focusTaskId)
              : EmployeeTaskTrackerScreenMobile(focusTaskId: focusTaskId),
        ),
      ),
    );
  }

  static void _openTasksAdmin(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => wide
            ? const TaskTrackerScreenDesktop()
            : const TaskTrackerScreenMobile(),
      ),
    );
  }

  static EmployeeBloc? _tryReadEmployeeBloc(BuildContext context) {
    try {
      return context.read<EmployeeBloc>();
    } catch (_) {
      return null;
    }
  }

  static void _openLeaveEmployee(BuildContext context, String leaveId) {
    Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute<void>(
        settings: RouteSettings(arguments: {'leave_id': leaveId}),
        builder: (_) => BlocProvider(
          create: (_) => LeaveBloc(LeaveApiService())..add(const LoadMyLeaves()),
          child: const EmployeeLeaveStatusScreen(),
        ),
      ),
    );
  }

  static void _openLeaveAdmin(BuildContext context, {required String focusLeaveId}) {
    Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute<void>(
        settings: RouteSettings(arguments: {'leave_id': focusLeaveId}),
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider<LeaveBloc>(
              create: (_) => LeaveBloc(LeaveApiService())..add(LoadPendingLeaves()),
            ),
            BlocProvider<LeaveDashboardBloc>(
              create: (_) => LeaveDashboardBloc(LeaveApiService())
                ..add(FetchDashboardCounts()),
            ),
          ],
          child: const AdminLeaveDashboard(),
        ),
      ),
    );
  }
}
