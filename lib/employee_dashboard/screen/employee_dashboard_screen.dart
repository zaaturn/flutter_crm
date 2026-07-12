import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/core/auth/shell_route_persistence.dart';
import 'package:my_app/event_management/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:my_app/event_management/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:my_app/event_management/features/dashboard/presentation/widgets/main_dashboard_events_panel.dart';
import 'package:my_app/survey/presentation/widgets/survey_feed_section.dart';
import 'package:my_app/employee_dashboard/widget/shared_posts_section.dart';
import '../bloc/employee_dashboard_bloc.dart';
import '../bloc/employee_dashboard_event.dart';
import '../bloc/employee_dashboard_state.dart';
import '../widget/top_bar.dart';
import '../widget/work_status_card.dart';
import '../widget/assigned_tasks_section.dart';
import '../widget/bottom_nav.dart';
import 'package:my_app/employee_dashboard/widget/device_specific/dashboard_greeting.dart';

class EmployeeDashboardScreen extends StatefulWidget {
  const EmployeeDashboardScreen({super.key});

  @override
  State<EmployeeDashboardScreen> createState() =>
      _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState extends State<EmployeeDashboardScreen> {
  StreamSubscription<RemoteMessage>? _fcmSubscription;

  @override
  void initState() {
    super.initState();
    ShellRoutePersistence.markEmployeeShell();
    final bloc = context.read<EmployeeBloc>();
    bloc.add(LoadDashboard());
    bloc.add(StartTaskPolling());
    bloc.add(RegisterNotificationDevice());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        context.read<NotificationBloc>().add(NotificationLoadRequested());
      } catch (_) {}
    });

    _fcmSubscription = FirebaseMessaging.onMessage.listen((message) {
      final type = '${message.data['type'] ?? ''}'.toLowerCase();
      if (type == 'task_assigned' ||
          type == 'task_updated' ||
          type == 'task_completed' ||
          type == 'task_approved' ||
          type == 'task_due_reminder') {
        if (!mounted) return;
        context.read<EmployeeBloc>().add(PollTasksRequested());
      }
    });
  }

  @override
  void dispose() {
    _fcmSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const EmployeeDashboardView();
  }
}

class EmployeeDashboardView extends StatelessWidget {
  const EmployeeDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF3E0),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TopBar(scaffoldContext: context),
            ),
            const Expanded(
              child: _DashboardBody(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmployeeBloc, EmployeeState>(
      builder: (context, state) {
        if (state.loading && state.attendance == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<EmployeeBloc>().add(LoadDashboard());
            context.read<DashboardBloc>().add(DashboardRefreshRequested());
            try {
              context.read<NotificationBloc>().add(NotificationLoadRequested());
            } catch (_) {}
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const DashboardGreeting(),
                const SizedBox(height: 16),
                const SessionOverviewSection(),
                const SizedBox(height: 32),
                AssignedTasksSection(
                  tasks: state.tasks,
                  onStatusChange: (taskId, status) {
                    context.read<EmployeeBloc>().add(
                      UpdateTaskStatus(
                        taskId: taskId,
                        status: status,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                const SurveyFeedSection(compact: true),
                const SizedBox(height: 24),
                const SharedPostsSection(),
                const SizedBox(height: 32),
                const MainDashboardEventsPanel(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}