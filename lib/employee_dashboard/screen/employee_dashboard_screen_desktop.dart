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
import 'package:my_app/employee_dashboard/widget/shared_posts_section.dart';

// ======================= SERVICES & SCREENS =======================
import 'package:my_app/screens/welcome_screen.dart';
import 'package:my_app/screens/device_specific/profile_screen_desktop.dart';
import 'package:my_app/leave_management/screens/device_specific/employee_leave_dashboard_desktop.dart';
import 'package:my_app/services/secure_storage_service.dart';
import 'package:my_app/services/api_client.dart';
import 'package:my_app/event_management/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:my_app/event_management/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:my_app/survey/presentation/widgets/survey_feed_section.dart';
import 'package:my_app/event_management/features/dashboard/presentation/widgets/main_dashboard_events_panel.dart';
import 'package:my_app/core/keyboard/keyboard_navigation.dart';

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
  final ScrollController _scrollController = ScrollController();
  final FocusNode _sidebarFocusNode = FocusNode(debugLabel: 'EmployeeSidebarFocus');
  final FocusNode _contentFocusNode = FocusNode(debugLabel: 'EmployeeContentFocus');

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        context.read<NotificationBloc>().add(NotificationLoadRequested());
      } catch (_) {}
    });

    _fcmSubscription = FirebaseMessaging.onMessage.listen((message) {
      if (message.data['type'] == 'TASK_ASSIGNED') {
        _employeeBloc.add(LoadDashboard());
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _sidebarFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _autoCheckoutTimer?.cancel();
    _fcmSubscription?.cancel();
    _scrollController.dispose();
    _sidebarFocusNode.dispose();
    _contentFocusNode.dispose();
    _employeeBloc.add(StopTaskPolling());
    super.dispose();
  }

  Future<void> _logout() async {
    await ApiClient().logout();
    await SecureStorageService().clearAll();
    _employeeBloc.add(StopTaskPolling());

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
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
                DashboardSidebarFocusScope(
                  focusNode: _sidebarFocusNode,
                  onMoveToContent: () => _contentFocusNode.requestFocus(),
                  child: DashboardSidebar(
                    parentContext: context,
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
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: state.loading
                                      ? const Center(
                                          child: CircularProgressIndicator(),
                                        )
                                      : KeyboardScrollRegion(
                                          scrollController: _scrollController,
                                          focusNode: _contentFocusNode,
                                          onMoveToPreviousRegion: () =>
                                              _sidebarFocusNode.requestFocus(),
                                          child: RefreshIndicator(
                                            onRefresh: () async {
                                              _employeeBloc.add(LoadDashboard());
                                              try {
                                                context
                                                    .read<DashboardBloc>()
                                                    .add(DashboardRefreshRequested());
                                              } catch (_) {}
                                              try {
                                                context
                                                    .read<NotificationBloc>()
                                                    .add(NotificationLoadRequested());
                                              } catch (_) {}
                                            },
                                            child: SingleChildScrollView(
                                              controller: _scrollController,
                                              physics:
                                                  const AlwaysScrollableScrollPhysics(),
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 40,
                                                vertical: 32,
                                              ),
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
                                                  const SurveyFeedSection(
                                                      compact: true),
                                                  const SizedBox(height: 24),
                                                  const SharedPostsSection(),
                                                  const SizedBox(height: 24),
                                                  const MainDashboardEventsPanel(),
                                                  const SizedBox(height: 24),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                ),

                                // ================= RIGHT PANEL (CALENDAR) =================
                                Container(
                                  width: 380,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border(
                                      left: BorderSide(
                                        color: Colors.grey.shade100,
                                      ),
                                    ),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.fromLTRB(12, 20, 12, 0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          child: DashboardCalendar(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
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