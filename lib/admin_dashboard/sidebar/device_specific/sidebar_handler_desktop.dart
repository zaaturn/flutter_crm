import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/assign_task_screen_desktop.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/track_task_desktop.dart';

import 'sidebar_menu_config_desktop.dart';

import 'package:my_app/main.dart';
import 'package:my_app/services/auth_service.dart';
import 'package:my_app/screens/welcome_screen.dart';


import 'package:my_app/admin_dashboard/bloc/admin_dashboard_bloc.dart';
import 'package:my_app/admin_dashboard/bloc/admin_dashboard_event.dart';
import 'package:my_app/admin_dashboard/repository/admin_repository.dart';

import 'package:my_app/billing/navigation/billing_flow_controller.dart';

import 'package:my_app/leave_management/block/leave_bloc.dart';
import 'package:my_app/leave_management/block/leave_event.dart';
import 'package:my_app/leave_management/services/leave_api_services.dart';
import 'package:my_app/leave_management/screens/admin_leave_list_screen.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/assign_task_screen_desktop.dart';

import 'package:my_app/event_management/features/presentation/screen/calendar_screen_desktop.dart';

import 'package:my_app/admin_dashboard/screen/device_specific/employee_list_screen_desktop.dart';
import 'package:my_app/admin_dashboard/bloc/employee_list_bloc.dart';
import 'package:my_app/admin_dashboard/bloc/employee_list_event.dart';
import 'package:my_app/admin_dashboard/repository/employee_list_repository.dart';

class SidebarHandler {
  static Future<void> handle(
      BuildContext sidebarContext,
      BuildContext parentContext,
      SidebarAction action,
      ) async {
    if (!kIsWeb && MediaQuery.of(sidebarContext).size.width < 900) {
      Navigator.pop(sidebarContext);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (action) {
        case SidebarAction.dashboard:
          break;

        case SidebarAction.employees:
          _push(
            parentContext,
            BlocProvider(
              create: (_) => EmployeeListBloc(
                repository: EmployeeRepository (),
              )..add(const FetchEmployees()),
              child: const EmployeeListScreen(),
            ),
          );
          break;

        case SidebarAction.trackTasks:
          _push(
            parentContext,
            BlocProvider(
              create: (_) => AdminDashboardBloc(
                repository: AdminRepository(),
              )..add(const AdminDashboardStarted()),
              child: const TaskTrackerScreenDesktop(),
            ),
          );
          break;

        case SidebarAction.assignTasks:
          _push(
            parentContext,
            const AssignTaskScreenDesktop(),
          );
          break;

        case SidebarAction.leaveManagement:
          _push(
            parentContext,
            BlocProvider(
              create: (_) => LeaveBloc(
                LeaveApiService(),
              )..add(LoadPendingLeaves()),
              child: const AdminLeaveListScreen(),
            ),
          );
          break;

        case SidebarAction.meetings:
        case SidebarAction.credentials:
        case SidebarAction.assets:
          break;

        case SidebarAction.billingGenerate:
          BillingFlowController.start(parentContext);
          break;

        case SidebarAction.payroll:
          break;

        case SidebarAction.leads:
          break;

        case SidebarAction.events:
          _push(parentContext, const CalendarScreenDesktop());
          break;

        case SidebarAction.logout:
          _handleLogout(parentContext);
          break;
      }
    });
  }

  static void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  static Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await AuthService().logout();

    navigatorKey.currentState!.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomePage()),
          (_) => false,
    );
  }
}
