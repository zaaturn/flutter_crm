import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_app/admin_dashboard/bloc/admin_dashboard_state.dart';
import 'package:my_app/admin_dashboard/bloc/admin_dashboard_bloc.dart';
import 'package:my_app/admin_dashboard/model/employee.dart';

import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/widgets/admin_dashboard_widgets/header.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/widgets/admin_dashboard_widgets/welcome_section.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/widgets/admin_dashboard_widgets/dashboard_grid.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/widgets/admin_dashboard_widgets/bottom_nav.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: SafeArea(
            child: Column(
              children: [
                const Header(),
                Expanded(
                  child: _buildBody(state),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNav(
            selectedIndex: _selectedIndex,
            onTap: (i) => setState(() => _selectedIndex = i),
          ),
        );
      },
    );
  }

  Widget _buildBody(AdminDashboardState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF3B82F6),
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Text(
          state.error!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    // 🔥 FINAL FIX: REMOVE INVALID EMPLOYEES
    final List<Employee> displayList = state.liveEmployees
        .where((e) => e.name.isNotEmpty) // remove broken objects
        .toList();

    // 🔍 DEBUG
    print("📱 CLEAN LIST:");
    for (var e in displayList) {
      print("${e.name} → ${e.liveStatus}");
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WelcomeSection(name: state.username ?? 'Admin'),
          const SizedBox(height: 24),

          DashboardGrid(
            employees: displayList,
          ),
        ],
      ),
    );
  }
}