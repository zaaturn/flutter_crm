import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/admin_dashboard_bloc.dart';
import '../bloc/admin_dashboard_state.dart';
import '../bloc/admin_dashboard_event.dart';

import '../sidebar/sidebar_drawer.dart';
import '../widget/welcome_header.dart';
import '../widget/employee_section.dart';
import '../widget/task_section.dart';
import '../widget/event_section.dart';

import 'package:my_app/admin_dashboard/repository/admin_repository.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminDashboardBloc(
        repository: AdminRepository(),
      )
      // Load dashboard data
        ..add(const AdminDashboardStarted())
      //  Register admin device for notifications
        ..add(const RegisterAdminNotificationDevice()),
      child: const _AdminDashboardView(),
    );
  }
}

class _AdminDashboardView extends StatelessWidget {
  const _AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final blocContext = context;

    return Scaffold(
      drawer: BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
        builder: (context, state) {
          if (state.username == null || state.role == null) {
            return const SizedBox.shrink();
          }

          return SidebarDrawer(
            parentContext: blocContext,
            userId: state.username!,
            userName: state.role!.toUpperCase(),
            userEmail: state.username!,
            userAvatar: null,
          );
        },
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: _ModernAppBar(),
      ),
      body: BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.error != null) {
            return Center(child: Text(state.error!));
          }

          return RefreshIndicator(
            onRefresh: () async {
              context
                  .read<AdminDashboardBloc>()
                  .add(const AdminDashboardRefreshed());
            },
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const _AnimatedCard(child: WelcomeHeader()),
                const SizedBox(height: 24),
                _AnimatedCard(
                  child: EmployeeSection(
                    employees: state.liveEmployees,
                  ),
                ),
                const SizedBox(height: 24),
                _AnimatedCard(
                  child: TaskSection(
                    tasks: state.tasks,
                  ),
                ),
                const SizedBox(height: 24),
                _AnimatedCard(
                  child: EventSection(
                    events: state.events,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ModernAppBar extends StatelessWidget {
  const _ModernAppBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF6366F1),
            Color(0xFF8B5CF6),
          ],
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu_rounded, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              'Admin Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(
                Icons.notifications_rounded,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedCard extends StatelessWidget {
  final Widget child;

  const _AnimatedCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: child,
    );
  }
}
