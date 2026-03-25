import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/employee_dashboard_bloc.dart';
import '../bloc/employee_dashboard_event.dart';
import '../bloc/employee_dashboard_state.dart';

import '../widget/top_bar.dart';
import '../widget/work_status_card.dart'; // Renamed to SessionOverviewSection inside
import '../widget/assigned_tasks_section.dart';
import '../widget/bottom_nav.dart';


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
    bloc.add(LoadDashboard());
    bloc.add(StartTaskPolling());
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
      // --- CHANGED TO PURE WHITE HERE ---
      backgroundColor: Colors.white,
      appBar: TopBar(scaffoldContext: context),
      body: const _DashboardBody(),
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
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
              ],
            ),
          ),
        );
      },
    );
  }
}