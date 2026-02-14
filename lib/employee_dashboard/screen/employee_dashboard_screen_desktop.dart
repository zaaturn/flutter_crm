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
import 'package:my_app/employee_dashboard/widget/device_specific/dashboard_event_section.dart';

// ======================= SERVICES & SCREENS =======================
import 'package:my_app/screens/welcome_screen.dart';
import 'package:my_app/leave_management/screens/device_specific/employee_leave_dashboard_desktop.dart';
import 'package:my_app/services/secure_storage_service.dart';
import 'package:my_app/services/api_client.dart';

class EmployeeDashboardDesktop extends StatefulWidget {
  const EmployeeDashboardDesktop({super.key});

  @override
  State<EmployeeDashboardDesktop> createState() => _EmployeeDashboardDesktopState();
}

class _EmployeeDashboardDesktopState extends State<EmployeeDashboardDesktop> {
  Timer? _autoCheckoutTimer;
  StreamSubscription<RemoteMessage>? _fcmSubscription;
  late EmployeeBloc _employeeBloc;

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
        body: Row(
          children: [
            // Sidebar Navigation
            DashboardSidebar(
              onLogout: _logout,
              onNavigateLeave: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EmployeeLeaveDashboardScreenDesktop(),
                  ),
                );
              },
              onNavigateTask: () {
                // Navigate to tasks
              },
            ),

            // Main Content Area
            Expanded(
              child: Column(
                children: [
                  // Top Bar
                  const DashboardTopBar(),

                  // Dashboard Content
                  Expanded(
                    child: BlocBuilder<EmployeeBloc, EmployeeState>(
                      builder: (context, state) {
                        if (state.loading) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        return RefreshIndicator(
                          onRefresh: () async {
                            _employeeBloc.add(LoadDashboard());
                          },
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(24),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // LEFT COLUMN - Main Content (70%)
                                Expanded(
                                  flex: 7,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Greeting Banner
                                      const DashboardGreeting(),
                                      const SizedBox(height: 24),

                                      // Work Status Card
                                      DashboardWorkStatusCard(
                                        attendance: state.attendance,
                                      ),
                                      const SizedBox(height: 24),

                                      // Active Tasks Section
                                      DashboardTasksSection(
                                        tasks: state.tasks,
                                        onUpdateStatus: (taskId, status) {
                                          _employeeBloc.add(UpdateTaskStatus(
                                            taskId: taskId,
                                            status: status,
                                          ));
                                        },
                                      ),
                                      const SizedBox(height: 24),

                                      // Calendar/Events Section
                                      DashboardEventsSection(
                                        events: state.events,
                                      ),
                                      const SizedBox(height: 24),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 24),

                                // RIGHT COLUMN - Sidebar (30%)
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Quick Stats Cards
                                      _buildQuickStatsCard(
                                        count: state.tasks
                                            .where((t) => t.status != 'completed')
                                            .length,
                                        label: 'ACTIVE',
                                        subtitle: 'Your current assigned tasks',
                                        icon: Icons.assignment,
                                        color: const Color(0xFF4F46E5),
                                      ),
                                      const SizedBox(height: 16),

                                      _buildQuickStatsCard(
                                        count: state.events.length,
                                        label: 'EVENTS',
                                        subtitle: 'Upcoming calendar events',
                                        icon: Icons.calendar_today,
                                        color: const Color(0xFF10B981),
                                      ),
                                      const SizedBox(height: 16),

                                      _buildQuickStatsCard(
                                        count: state.sharedItems.length,
                                        label: 'SHARED',
                                        subtitle: 'Shared with you recently',
                                        icon: Icons.folder_shared,
                                        color: const Color(0xFFF59E0B),
                                      ),
                                      const SizedBox(height: 24),

                                      // Recent Shared Items Section
                                      DashboardSharedItemsSection(
                                        items: state.sharedItems,
                                      ),
                                      const SizedBox(height: 24),

                                      // Quick Actions (optional)
                                      _buildQuickActions(),
                                    ],
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

  // Quick Stats Card Widget
  Widget _buildQuickStatsCard({
    required int count,
    required String label,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '$count',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Quick Actions Widget (Optional)
  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'QUICK ACTIONS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.add_circle_outline,
                  label: 'New Task',
                  onTap: () {
                    // Navigate to create task
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.access_time,
                  label: 'Log Time',
                  onTap: () {
                    // Navigate to time log
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: const Color(0xFF1F2937)),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ),
    );
  }
}