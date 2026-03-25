import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/admin_dashboard/bloc/admin_dashboard_state.dart';
import 'package:my_app/admin_dashboard/bloc/admin_dashboard_bloc.dart';
import 'package:my_app/admin_dashboard/model/employee.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/widgets/admin_dashboard_widgets/header.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/widgets/admin_dashboard_widgets/welcome_section.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/widgets/admin_dashboard_widgets/dashboard_grid.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/widgets/admin_dashboard_widgets/bottom_nav.dart';

import 'employee_list_screen_mobile.dart';

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
          backgroundColor: const Color(0xFFF8FAFC),
          body: IndexedStack(
            index: _selectedIndex,
            children: [
              _buildHomeTab(state),

              EmployeeListScreenMobile(
                onBack: () => setState(() => _selectedIndex = 0),
              ),

              _buildPlaceholder("Messages"),
              _buildPlaceholder("Profile"),
            ],
          ),
          bottomNavigationBar: BottomNav(
            selectedIndex: _selectedIndex,
            onTap: (i) => setState(() => _selectedIndex = i),
          ),
        );
      },
    );
  }

  Widget _buildHomeTab(AdminDashboardState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6366F1)),
      );
    }

    final List<Employee> displayList = state.liveEmployees.where((e) {
      return e.firstName.trim().isNotEmpty ||
          e.lastName.trim().isNotEmpty ||
          e.name.trim().isNotEmpty;
    }).toList();

    return SafeArea(
      child: Column(
        children: [
          const Header(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WelcomeSection(
                    firstName: state.user?.firstName ?? (state.username ?? 'Admin'),
                    lastName: state.user?.lastName ?? '',
                  ),

                  const SizedBox(height: 32),

                  DashboardGrid(employees: displayList),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(String title) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF64748B),
        ),
      ),
    );
  }
}