import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/employee_dashboard_bloc.dart';
import '../bloc/employee_dashboard_event.dart';
import '../bloc/employee_dashboard_state.dart';

import '../widget/top_bar.dart';
import '../widget/greeting_header.dart';
import '../widget/work_status_card.dart';
import '../widget/assigned_tasks_section.dart';
import '../widget/shared_items_section.dart';
import '../widget/event_section.dart';
import '../widget/bottom_nav.dart';
import '../widget/app_drawer.dart';

class EmployeeDashboardScreen extends StatefulWidget {
  const EmployeeDashboardScreen({super.key});

  @override
  State<EmployeeDashboardScreen> createState() =>
      _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState
    extends State<EmployeeDashboardScreen> {

  @override
  void initState() {
    super.initState();

    final bloc = context.read<EmployeeBloc>();

    // Load dashboard data
    bloc.add(LoadDashboard());

    // Start polling
    bloc.add(StartTaskPolling());

    // 🔔 Register notification device (clean call)
    bloc.add(RegisterNotificationDevice());
  }

  @override
  void dispose() {
    context.read<EmployeeBloc>().add(StopTaskPolling());
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
      backgroundColor: const Color(0xFFF7F9FC),
      drawer: AppDrawer(),
      body: SafeArea(
        child: Builder(
          builder: (innerContext) {
            return Column(
              children: [
                TopBar(scaffoldContext: innerContext),
                const Expanded(child: _DashboardBody()),
                const BottomNav(),
              ],
            );
          },
        ),
      ),
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
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const GreetingHeader(),
                const SizedBox(height: 20),

                WorkStatusCard(att: state.attendance),
                const SizedBox(height: 20),

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

                const SizedBox(height: 20),

                SharedItemsSection(items: state.sharedItems),
                const SizedBox(height: 20),

                EventSection(events: state.events),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}
