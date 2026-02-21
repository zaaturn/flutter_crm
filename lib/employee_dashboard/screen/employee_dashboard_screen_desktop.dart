import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// ======================= BLOC =======================
import 'package:my_app/employee_dashboard/bloc/employee_dashboard_bloc.dart';
import 'package:my_app/employee_dashboard/bloc/employee_dashboard_event.dart';
import 'package:my_app/employee_dashboard/bloc/employee_dashboard_state.dart';

// ======================= WIDGETS =======================
import 'package:my_app/employee_dashboard/widget/device_specific/dashboard_sidebar.dart';
import 'package:my_app/employee_dashboard/widget/device_specific/dashboard_topbar.dart';
import 'package:my_app/employee_dashboard/widget/device_specific/dashboard_greeting.dart';
import 'package:my_app/employee_dashboard/widget/device_specific/dashboard_task_section.dart';
import 'package:my_app/employee_dashboard/widget/device_specific/dashboard_share_item_section.dart';
import 'package:my_app/employee_dashboard/widget/device_specific/dashboard_workstatus_card.dart';
import 'package:my_app/admin_dashboard/widget/device_specific/calender_desktop.dart';

// ======================= SERVICES & SCREENS =======================
import 'package:my_app/screens/welcome_screen.dart';
import 'package:my_app/leave_management/screens/device_specific/employee_leave_dashboard_desktop.dart';
import 'package:my_app/services/secure_storage_service.dart';
import 'package:my_app/services/api_client.dart';

class EmployeeDashboardDesktop extends StatefulWidget {
  const EmployeeDashboardDesktop({super.key});

  @override
  State<EmployeeDashboardDesktop> createState() =>
      _EmployeeDashboardDesktopState();
}

class _EmployeeDashboardDesktopState
    extends State<EmployeeDashboardDesktop> {
  Timer? _autoCheckoutTimer;
  StreamSubscription<RemoteMessage>? _fcmSubscription;
  late EmployeeBloc _employeeBloc;

  @override
  void initState() {
    super.initState();
    _employeeBloc = context.read<EmployeeBloc>();

    _employeeBloc.add(LoadDashboard());
    _employeeBloc.add(StartTaskPolling());

    _fcmSubscription =
        FirebaseMessaging.onMessage.listen((message) {
          if (message.data['type'] == 'TASK_ASSIGNED') {
            _employeeBloc.add(LoadDashboard());
          }
        });
  }

  @override
  void dispose() {
    _autoCheckoutTimer?.cancel();
    _fcmSubscription?.cancel();
    _employeeBloc.add(StopTaskPolling());
    super.dispose();
  }

  Future<void> _logout() async {
    await ApiClient().logout();
    await SecureStorageService().clearAll();
    _employeeBloc.add(StopTaskPolling());

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomePage()),
          (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: Row(
          children: [
            // Sidebar Navigation
            DashboardSidebar(
              onLogout: _logout,
              onNavigateLeave: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const EmployeeLeaveDashboardScreenDesktop(),
                  ),
                );
              },
              onNavigateTask: () {},
            ),

            // Main Content Area
            Expanded(
              child: Column(
                children: [
                  const DashboardTopBar(),

                  Expanded(
                    child: BlocBuilder<EmployeeBloc, EmployeeState>(
                      builder: (context, state) {
                        if (state.loading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        return RefreshIndicator(
                          onRefresh: () async {
                            _employeeBloc.add(LoadDashboard());
                          },
                          child: SingleChildScrollView(
                            physics:
                            const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(24),
                            child: Row(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                // LEFT COLUMN (UNCHANGED)
                                Expanded(
                                  flex: 7,
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const DashboardGreeting(),
                                      const SizedBox(height: 24),

                                      DashboardWorkStatusCard(),
                                      const SizedBox(height: 24),

                                      DashboardTasksSection(
                                        tasks: state.tasks,
                                        onUpdateStatus:
                                            (taskId, status) {
                                          _employeeBloc.add(
                                            UpdateTaskStatus(
                                              taskId: taskId,
                                              status: status,
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 24),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 24),

                                // RIGHT COLUMN (ONLY THIS CHANGED)
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    height: 700,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                      BorderRadius.circular(12),
                                      border: Border.all(
                                          color:
                                          const Color(0xFFE5E7EB),
                                          width: 1),
                                    ),
                                    child: const DashboardCalendar(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}