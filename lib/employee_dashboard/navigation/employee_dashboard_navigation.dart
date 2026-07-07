import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/core/ui/adaptive_layout.dart';
import 'package:my_app/auth/auth_session.dart';
import 'package:my_app/services/auth_service.dart';
import 'package:my_app/main.dart' show navigatorKey;

// SCREEN IMPORTS
import '../screen/employee_dashboard_screen.dart';
import 'package:my_app/employee_dashboard/screen/employee_dashboard_screen_desktop.dart';

// ================= BLOC =================
import 'package:my_app/leave_management/block/leave_bloc.dart';
import 'package:my_app/leave_management/block/leave_event.dart';
import 'package:my_app/leave_management/services/leave_api_services.dart';

// ================= mobile SCREENS =================
import 'package:my_app/leave_management/screens/employee_leave_dashboard.dart';
import 'package:my_app/leave_management/screens/apply_leave_screen.dart';
import 'package:my_app/leave_management/screens/employee_leave_status_screen.dart';
import 'package:my_app/leave_management/screens/public_holiday_calender.dart';
import 'package:my_app/employee_dashboard/widget/employee_task_tracker_screen_mobile.dart';

// ================= DESKTOP / WEB SCREENS =================
import 'package:my_app/leave_management/screens/device_specific/employee_leave_dashboard_desktop.dart';
import 'package:my_app/leave_management/screens/device_specific/apply_leave_screen_desktop.dart';
import 'package:my_app/leave_management/screens/device_specific/employee_leave_status_screen_desktop.dart';
import 'package:my_app/leave_management/screens/device_specific/public_holiday_desktop.dart';
import 'package:my_app/employee_dashboard/screen/employee_task_tracker_screen.dart';
import 'package:my_app/employee_dashboard/screen/employee_feed_screen_desktop.dart';
import 'package:my_app/dashboards/presentations/screens/feed_screen_mobile.dart';
import 'package:my_app/event_management/shared/widgets/event_management_shell.dart';

class EmployeeDashboardNavigator {

  static bool _isDesktop(BuildContext context) {
    return AdaptiveLayout.isDesktopLikePlatform();
  }

  // ================= FIXED TAB NAVIGATION HELPER =================
  /// Uses [navigatorKey] so we always mutate the same [Navigator] as [MaterialApp]
  /// (web / nested routes: `Navigator.of(context, rootNavigator: true)` can be wrong
  /// and leave `_history` empty after `pushAndRemoveUntil`).
  static void _switchTab(BuildContext context, Widget screen) {
    _safeCloseDrawer(context);
    unawaited(AuthService().setActiveDashboard(ActiveDashboard.employee));

    void push(NavigatorState nav) {
      if (!nav.mounted) return;
      nav.pushAndRemoveUntil<void>(
        PageRouteBuilder<void>(
          pageBuilder: (_, __, ___) => screen,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
        (route) => false,
      );
    }

    final keyed = navigatorKey.currentState;
    if (keyed != null && keyed.mounted) {
      push(keyed);
      return;
    }

    final nav = Navigator.maybeOf(context, rootNavigator: true);
    if (nav != null && nav.mounted) {
      push(nav);
    }
  }

  // ================= MAIN DASHBOARD =================
  static void dashboard(BuildContext context) {
    _switchTab(
      context,
      _isDesktop(context)
          ? const EmployeeDashboardDesktop()
          : const EmployeeDashboardScreen(),
    );
  }

  /// Leave Management back: if this screen was [Navigator.push] on top of the main
  /// dashboard (e.g. desktop sidebar), pop once. If it is the **only** route
  /// (bottom nav replaced the stack with leave), [Navigator.pop] would empty
  /// history — use [dashboard] instead.
  static void leaveBackToMain(BuildContext context) {
    final nav = navigatorKey.currentState;
    if (nav != null && nav.mounted && nav.canPop()) {
      nav.pop();
      return;
    }
    final ctx = navigatorKey.currentContext ?? context;
    dashboard(ctx);
  }

  // ================= TASK TRACKER =================
  static void tasks(BuildContext context) {
    _switchTab(
      context,
      _isDesktop(context)
          ? const EmployeeTaskTrackerScreen()
          : const EmployeeTaskTrackerScreenMobile(),
    );
  }

  // ================= LEAVE DASHBOARD =================
  static void leaveDashboard(BuildContext context) {
    _switchTab(
      context,
      BlocProvider(
        create: (_) => LeaveBloc(LeaveApiService())
          ..add(const LoadMyLeaves())
          ..add(const LoadLeaveBalances()),
        child: _isDesktop(context)
            ? const EmployeeLeaveDashboardScreenDesktop()
            : const EmployeeLeaveDashboardScreen(),
      ),
    );
  }

  // ================= EVENTS =================
  static Future<void> events(BuildContext context) {
    _safeCloseDrawer(context);
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EventManagementShell()),
    );
  }

  // ================= FEED / SHARED POSTS =================
  static void feed(BuildContext context) {
    _switchTab(
      context,
      _isDesktop(context)
          ? const EmployeeFeedScreenDesktop()
          : const FeedScreenMobile(),
    );
  }

  // ================= SUB-SCREENS (STANDARD PUSH) =================
  static void applyLeave(BuildContext context) {
    _safeCloseDrawer(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => LeaveBloc(LeaveApiService())
            ..add(const LoadLeaveTypes())
            ..add(const LoadLeaveBalances()),
          child: _isDesktop(context)
              ? const ApplyLeaveScreenDesktop()
              : const ApplyLeaveScreen(),
        ),
      ),
    );
  }

  static void leaveStatus(BuildContext context) {
    _safeCloseDrawer(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => LeaveBloc(LeaveApiService())..add(const LoadMyLeaves()),
          child: _isDesktop(context)
              ? const EmployeeLeaveStatusScreenDesktop()
              : const EmployeeLeaveStatusScreen(),
        ),
      ),
    );
  }

  static void holidayCalendar(BuildContext context) {
    _safeCloseDrawer(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _isDesktop(context)
            ? const PublicHolidayCalendarScreenDesktop()
            : const PublicHolidayCalendarScreen(),
      ),
    );
  }

  static void _safeCloseDrawer(BuildContext context) {
    final scaffold = Scaffold.maybeOf(context);
    if (scaffold != null && scaffold.isDrawerOpen) {
      Navigator.pop(context);
    }
  }
}