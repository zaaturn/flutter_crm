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

// ================= DESKTOP / WEB SCREENS =================
import 'package:my_app/leave_management/screens/device_specific/employee_leave_dashboard_desktop.dart';
import 'package:my_app/leave_management/screens/device_specific/apply_leave_screen_desktop.dart';
import 'package:my_app/leave_management/screens/device_specific/employee_leave_status_screen_desktop.dart';
import 'package:my_app/leave_management/screens/device_specific/public_holiday_desktop.dart';
import 'package:my_app/event_management/features/presentation/screen/calendar_screen.dart';
import 'package:my_app/event_management/features/presentation/screen/calendar_screen_desktop.dart';
import 'package:my_app/employee_dashboard/screen/employee_task_tracker_screen.dart';



class EmployeeDashboardNavigator {
  // ================= DEVICE CHECK =================
  static bool _isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 900;
  }

  // ================= MAIN DASHBOARD =================
  static void dashboard(BuildContext context) {
    _safeCloseDrawer(context);

    Navigator.of(context, rootNavigator: true).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const EmployeeDashboardScreen(),
      ),
    );
  }

  // ================= TASK TRACKER =================
  static void tasks(BuildContext context) {
    _safeCloseDrawer(context);

    if (!_isDesktop(context)) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EmployeeTaskTrackerScreen(),
      ),
    );
  }






  // ================= LEAVE DASHBOARD =================
  static void leaveDashboard(BuildContext context) {
    _safeCloseDrawer(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) =>
          LeaveBloc(LeaveApiService())..add(const LoadMyLeaves()),
          child: _isDesktop(context)
              ? const EmployeeLeaveDashboardScreenDesktop()
              : const EmployeeLeaveDashboardScreen(),
        ),
      ),
    );
  }

  // ================= APPLY LEAVE =================
  static void applyLeave(BuildContext context) {
    _safeCloseDrawer(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) =>
          LeaveBloc(LeaveApiService())..add(const LoadLeaveTypes()),
          child: _isDesktop(context)
              ? const ApplyLeaveScreenDesktop()
              : const ApplyLeaveScreen(),
        ),
      ),
    );
  }

  // ================= LEAVE STATUS =================
  static void leaveStatus(BuildContext context) {
    _safeCloseDrawer(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) =>
          LeaveBloc(LeaveApiService())..add(const LoadMyLeaves()),
          child: _isDesktop(context)
              ? const EmployeeLeaveStatusScreenDesktop()
              : const EmployeeLeaveStatusScreen(),
        ),
      ),
    );
  }

  // ================= PUBLIC HOLIDAY =================
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
  // ================= EVENTS =================
  static void events(BuildContext context) {
    _safeCloseDrawer(context);
    Navigator.pushNamed(context, '/calendar');
  }



  // ================= SAFE DRAWER CLOSE =================
  static void _safeCloseDrawer(BuildContext context) {
    final scaffold = Scaffold.maybeOf(context);
    if (scaffold != null && scaffold.isDrawerOpen) {
      Navigator.pop(context);
    }
  }
}

