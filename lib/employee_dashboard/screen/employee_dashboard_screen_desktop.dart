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
import 'package:my_app/employee_dashboard/widget/device_specific/dashboard_workstatus_card.dart';
import 'package:my_app/admin_dashboard/widget/device_specific/calender_desktop.dart';
import 'package:my_app/event_management/features/dashboard/presentation/widgets/main_dashboard_events_panel.dart';
import 'package:my_app/employee_dashboard/widget/shared_posts_section.dart';

// ======================= SERVICES & SCREENS =======================
import 'package:my_app/screens/welcome_screen.dart';
import 'package:my_app/screens/device_specific/profile_screen_desktop.dart';
import 'package:my_app/leave_management/screens/device_specific/employee_leave_dashboard_desktop.dart';
import 'package:my_app/services/secure_storage_service.dart';
import 'package:my_app/services/api_client.dart';
import 'package:my_app/event_management/features/dashboard/presentation/bloc/dashboard_bloc.dart';

class EmployeeDashboardDesktop extends StatefulWidget {
  const EmployeeDashboardDesktop({super.key});

  @override
  State<EmployeeDashboardDesktop> createState() =>
      _EmployeeDashboardDesktopState();
}

class _EmployeeDashboardDesktopState extends State<EmployeeDashboardDesktop> {
  Timer? _autoCheckoutTimer;
  StreamSubscription<RemoteMessage>? _fcmSubscription;
  late EmployeeBloc _employeeBloc;

  bool _showProfilePanel = false;

  void _toggleProfilePanel() {
    setState(() {
      _showProfilePanel = !_showProfilePanel;
    });
  }

  @override
  void initState() {
    super.initState();
    _employeeBloc = context.read<EmployeeBloc>();

    _employeeBloc.add(LoadDashboard());
    _employeeBloc.add(StartTaskPolling());

    _fcmSubscription = FirebaseMessaging.onMessage.listen((message) {
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
        body: Stack(
          children: [
            // ================= MAIN DASHBOARD =================
            Row(
              children: [
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
                  onNavigateTask: () {
                    // Logic for task navigation if needed
                  },
                ),
                Expanded(
                  child: Column(
                    children: [
                      DashboardTopBar(
                        onProfileClick: _toggleProfilePanel,
                      ),
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
                                // Ensure DashboardBloc is available in context if using it here
                                try {
                                  context.read<DashboardBloc>().add(DashboardRefreshRequested());
                                } catch (_) {}
                              },
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(24),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // LEFT COLUMN: Content (Flex 7)
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
                                            onUpdateStatus: (taskId, status) {
                                              _employeeBloc.add(
                                                UpdateTaskStatus(
                                                  taskId: taskId,
                                                  status: status,
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 24),
                                          const SharedPostsSection(),
                                          const SizedBox(height: 24),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(width: 24),

                                    // RIGHT COLUMN: Calendar
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                        height: 850,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: const Color(0xFFF5F3FF),
                                            width: 1.2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.03),
                                              blurRadius: 20,
                                              offset: const Offset(0, 10),
                                            ),
                                          ],
                                        ),
                                        child: const ClipRRect(
                                          borderRadius: BorderRadius.all(Radius.circular(16)),
                                          child: DashboardCalendar(),
                                        ),
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

            // ================= DIM BACKGROUND =================
            if (_showProfilePanel)
              GestureDetector(
                onTap: _toggleProfilePanel,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  color: Colors.black.withOpacity(0.4),
                ),
              ),

            // ================= SLIDE PROFILE PANEL =================
            AnimatedPositioned(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutQuart,
              right: _showProfilePanel ? 0 : -420,
              top: 0,
              bottom: 0,
              child: Container(
                width: 420,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 40,
                      offset: const Offset(-10, 0),
                    ),
                  ],
                ),
                child: const ProfileScreenDesktop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}