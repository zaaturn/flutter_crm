import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/assign_task_screen_desktop.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/track_task_desktop.dart';

import 'sidebar_menu_config_desktop.dart';

import 'package:my_app/core/auth/auth_session_redirect.dart';


import 'package:my_app/admin_dashboard/bloc/admin_dashboard_bloc.dart';
import 'package:my_app/admin_dashboard/bloc/admin_dashboard_event.dart';
import 'package:my_app/admin_dashboard/repository/admin_repository.dart';

import 'package:my_app/analytics/navigation/analytics_flow_controller.dart';
import 'package:my_app/billing/navigation/billing_flow_controller.dart';
import 'package:my_app/payroll/navigation/payroll_flow_controller.dart';
import 'package:my_app/asset_management/navigation/asset_flow_controller.dart';

import 'package:my_app/leave_management/block/leave_bloc.dart';
import 'package:my_app/leave_management/block/leave_event.dart';
import 'package:my_app/leave_management/services/leave_api_services.dart';
import 'package:my_app/leave_management/screens/device_specific/admin_leave_approve_panel.dart';

import 'package:my_app/leave_management/block/leave_dashboard_bloc.dart';
import 'package:my_app/leave_management/block/leave_dashboard_event.dart';

import 'package:my_app/event_management/shared/widgets/event_management_shell.dart';

import 'package:my_app/admin_dashboard/screen/device_specific/employee_list_screen_desktop.dart';
import 'package:my_app/admin_dashboard/bloc/employee_list_bloc.dart';
import 'package:my_app/admin_dashboard/bloc/employee_list_event.dart';
import 'package:my_app/admin_dashboard/repository/employee_list_repository.dart';
import 'package:my_app/dashboards/presentations/screens/content_management_page.dart';
import 'package:my_app/client tracker/core/layout/app_shell.dart';
import 'package:my_app/client tracker/features/clients/bloc/client_bloc.dart';
import 'package:my_app/client tracker/features/payment/bloc/payment_bloc.dart';
import 'package:my_app/client tracker/features/clients/repository/client_repository.dart';
import 'package:my_app/client tracker/features/payment/repository/payment_repository.dart';
import 'package:my_app/auth/auth_session.dart';
import 'package:my_app/auth/screens/superadmin_users_screen.dart';
import 'package:my_app/services/secure_storage_service.dart';

class SidebarHandler {
  static Future<void> handle(
      BuildContext sidebarContext,
      BuildContext parentContext,
      SidebarAction action,
      ) async {
    // Only close a drawer — never Navigator.pop on a permanent sidebar (would pop the
    // whole route and can empty the stack → Navigator _history.isNotEmpty assertion).
    final scaffold = Scaffold.maybeOf(sidebarContext);
    if (scaffold != null && scaffold.isDrawerOpen) {
      Navigator.pop(sidebarContext);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!parentContext.mounted) return;

      if (action == SidebarAction.superadminUsers) {
        final raw = await SecureStorageService().readAuthSessionJson();
        if (!parentContext.mounted) return;
        final session = AuthSession.fromStorageString(raw);
        if (session?.isSuperuser != true) {
          _showLimitedAccess(parentContext);
          return;
        }
      } else {
        final key = moduleKeyForSidebarAction(action);
        if (key != null) {
          final raw = await SecureStorageService().readAuthSessionJson();
          if (!parentContext.mounted) return;
          final session = AuthSession.fromStorageString(raw);
          final allowed = key == 'payroll'
              ? (session?.canAccessPayrollAdmin ?? false)
              : key == 'analytics'
                  ? (session?.isSuperuser == true ||
                      session?.adminModules['analytics'] == true)
                  : (session?.moduleAllowed(key) ?? true);
          if (!allowed) {
            _showLimitedAccess(parentContext);
            return;
          }
        }
      }

      if (!parentContext.mounted) return;

      switch (action) {
        case SidebarAction.analytics:
          AnalyticsFlowController.openWithPermissionCheck(parentContext);
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
          AdminDashboardBloc? dashboardBloc;
          try {
            dashboardBloc = parentContext.read<AdminDashboardBloc>();
          } catch (_) {}

          _push(
            parentContext,
            dashboardBloc != null
                ? BlocProvider.value(
                    value: dashboardBloc,
                    child: const TaskTrackerScreenDesktop(),
                  )
                : const TaskTrackerScreenDesktop(),
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
            MultiBlocProvider(
              providers: [
                BlocProvider<LeaveBloc>(
                  create: (_) => LeaveBloc(
                    LeaveApiService(),
                  )..add(LoadPendingLeaves()),
                ),


                BlocProvider<LeaveDashboardBloc>(
                  create: (_) => LeaveDashboardBloc(
                    LeaveApiService(),
                  )..add(FetchDashboardCounts()),
                ),
              ],
              child: const AdminLeaveDashboard(),
            ),
          );
          break;

        case SidebarAction.share:
          _push(
            parentContext,
            const ContentManagementPage(),
          );
          break;
        case SidebarAction.client:
          _push(
            parentContext,
            MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) => ClientBloc(ClientRepository()),
                ),
                BlocProvider(
                  create: (_) => PaymentBloc(PaymentRepository()),
                ),
              ],
              child: const AppShell(),
            ),
          );
          break;

        case SidebarAction.assets:
          AssetFlowController.openAdmin(parentContext);
          break;

        case SidebarAction.billingGenerate:
          BillingFlowController.start(parentContext);
          break;

        case SidebarAction.payroll:
          PayrollFlowController.open(parentContext);
          break;

        case SidebarAction.leads:
          break;

        case SidebarAction.events:
          _push(parentContext, const EventManagementShell());
          break;

        case SidebarAction.superadminUsers:
          _push(parentContext, const SuperadminUsersScreen());
          break;

        case SidebarAction.logout:
          await _handleLogout(parentContext);
          break;
      }
    });
  }

  static void _showLimitedAccess(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limited access'),
        content: const Text(
          'Your admin account does not include this module. Contact a superadmin if you need access.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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

    await AuthSessionRedirect.logoutAndGoToLogin();
  }
}
