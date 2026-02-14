import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'sidebar_menu_config.dart';

import 'package:my_app/main.dart';
import 'package:my_app/services/auth_service.dart';
import 'package:my_app/screens/welcome_screen.dart';


import 'package:my_app/admin_dashboard/screen/assign_task_screen.dart';
import 'package:my_app/admin_dashboard/screen/task_tracker_screen.dart';

import 'package:my_app/admin_dashboard/bloc/admin_dashboard_bloc.dart';
import 'package:my_app/admin_dashboard/bloc/admin_dashboard_event.dart';
import 'package:my_app/admin_dashboard/repository/admin_repository.dart';

import 'package:my_app/billing/navigation/billing_flow_controller.dart';

import 'package:my_app/leave_management/block/leave_bloc.dart';
import 'package:my_app/leave_management/block/leave_event.dart';
import 'package:my_app/leave_management/services/leave_api_services.dart';
import 'package:my_app/leave_management/screens/admin_leave_list_screen.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/track_task_desktop.dart';

class SidebarHandler {
  static Future<void> handle(
      BuildContext drawerContext,
      BuildContext parentContext,
      SidebarAction action,
      ) async {

    Navigator.pop(drawerContext);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (action) {

      // ================= DASHBOARD =================
        case SidebarAction.dashboard:
          break;

      // ================= EMPLOYEES =================
        case SidebarAction.employees:
          break;

      // ================= PROJECTS & TASKS =================
        case SidebarAction.trackTasks:
          Navigator.push(
            parentContext,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) => AdminDashboardBloc(
                  repository: AdminRepository(),
                )..add(const AdminDashboardStarted()),
                child: const TaskTrackerScreen(),
              ),
            ),
          );
          break;

        case SidebarAction.assignTasks:
          Navigator.push(
            parentContext,
            MaterialPageRoute(
              builder: (_) => const AssignTaskScreen(),
            ),
          );
          break;

      // ================= LEAVE MANAGEMENT =================
        case SidebarAction.leaveManagement:
          Navigator.push(
            parentContext,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) => LeaveBloc(
                  LeaveApiService(),
                )..add(LoadPendingLeaves()),
                child: const AdminLeaveListScreen(),
              ),
            ),
          );
          break;

      // ================= MANAGEMENT =================
        case SidebarAction.meetings:
          break;

        case SidebarAction.credentials:
          break;

        case SidebarAction.assets:
          break;

      // ================= FINANCE =================
        case SidebarAction.billingGenerate:
          BillingFlowController.start(parentContext);
          break;

        case SidebarAction.payroll:
          break;

      // ================= OTHERS =================
        case SidebarAction.leads:
          break;

        case SidebarAction.reports:
          break;

      // ================= LOGOUT =================
        case SidebarAction.logout:
          _handleLogout(parentContext);
          break;
      }
    });
  }

  // ================= LOGOUT HANDLER =================

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
