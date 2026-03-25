import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../screen/employee_dashboard_screen.dart';

// ================= BLOC =================
import 'package:my_app/leave_management/block/leave_bloc.dart';
import 'package:my_app/leave_management/block/leave_event.dart';
import 'package:my_app/leave_management/services/leave_api_services.dart';

// ================= MOBILE SCREENS =================
import 'package:my_app/leave_management/screens/employee_leave_dashboard.dart';
import 'package:my_app/leave_management/screens/apply_leave_screen.dart';
import 'package:my_app/leave_management/screens/employee_leave_status_screen.dart';
import 'package:my_app/leave_management/screens/public_holiday_calender.dart';
// --> NEW: Added Mobile Task Tracker Import
import 'package:my_app/employee_dashboard/widget/employee_task_tracker_screen_mobile.dart';

// ================= DESKTOP / WEB SCREENS =================
import 'package:my_app/leave_management/screens/device_specific/employee_leave_dashboard_desktop.dart';
import 'package:my_app/leave_management/screens/device_specific/apply_leave_screen_desktop.dart';
import 'package:my_app/leave_management/screens/device_specific/employee_leave_status_screen_desktop.dart';
import 'package:my_app/leave_management/screens/device_specific/public_holiday_desktop.dart';
import 'package:my_app/event_management/features/presentation/screen/calendar_screen.dart';
import 'package:my_app/event_management/features/presentation/screen/calendar_screen_desktop.dart';
import 'package:my_app/employee_dashboard/screen/employee_task_tracker_screen.dart';

// Import your model
import '../model/task_model.dart';

class EmployeeDashboardNavigator {
  // ================= DEVICE CHECK =================
  static bool _isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 900;
  }

  // ================= TAB NAVIGATION HELPER =================
  // NEW: Provides instant, native-feeling tab switching without stacking pages in memory.
  static void _switchTab(BuildContext context, Widget screen) {
    _safeCloseDrawer(context);
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => screen,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  // ================= MAIN DASHBOARD =================
  static void dashboard(BuildContext context) {
    _switchTab(context, const EmployeeDashboardScreen());
  }

  // ================= TASK TRACKER (MODIFIED) =================
  static void tasks(BuildContext context) {
    // Correctly routes to desktop or mobile without blocking mobile devices
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
        create: (_) => LeaveBloc(LeaveApiService())..add(const LoadMyLeaves()),
        child: _isDesktop(context)
            ? const EmployeeLeaveDashboardScreenDesktop()
            : const EmployeeLeaveDashboardScreen(),
      ),
    );
  }

  // ================= EVENTS =================
  static void events(BuildContext context) {
    _safeCloseDrawer(context);
    // pushReplacementNamed prevents infinite back-stacks on bottom nav tabs
    Navigator.pushReplacementNamed(context, '/calendar');
  }

  // ================= APPLY LEAVE (SUB-SCREEN) =================
  static void applyLeave(BuildContext context) {
    _safeCloseDrawer(context);

    // Standard push used here so the user can use the physical/app back button
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => LeaveBloc(LeaveApiService())..add(const LoadLeaveTypes()),
          child: _isDesktop(context)
              ? const ApplyLeaveScreenDesktop()
              : const ApplyLeaveScreen(),
        ),
      ),
    );
  }

  // ================= LEAVE STATUS (SUB-SCREEN) =================
  static void leaveStatus(BuildContext context) {
    _safeCloseDrawer(context);

    // Standard push used here so the user can use the physical/app back button
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

  // ================= PUBLIC HOLIDAY (SUB-SCREEN) =================
  static void holidayCalendar(BuildContext context) {
    _safeCloseDrawer(context);

    // Standard push used here so the user can use the physical/app back button
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _isDesktop(context)
            ? const PublicHolidayCalendarScreenDesktop()
            : const PublicHolidayCalendarScreen(),
      ),
    );
  }

  // ================= SAFE DRAWER CLOSE =================
  static void _safeCloseDrawer(BuildContext context) {
    final scaffold = Scaffold.maybeOf(context);
    if (scaffold != null && scaffold.isDrawerOpen) {
      Navigator.pop(context);
    }
  }
}