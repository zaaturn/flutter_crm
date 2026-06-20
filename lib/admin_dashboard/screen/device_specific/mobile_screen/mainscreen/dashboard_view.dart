import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/admin_dashboard/bloc/admin_dashboard_state.dart';
import 'package:my_app/admin_dashboard/bloc/admin_dashboard_bloc.dart';
import 'package:my_app/admin_dashboard/bloc/admin_dashboard_event.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/widgets/admin_dashboard_widgets/bottom_nav.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/widgets/admin_dashboard_widgets/admin_top_bar_mobile.dart';
import 'package:my_app/admin_dashboard/model/employee.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/widgets/admin_dashboard_widgets/dashboard_grid.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/mainscreen/mobile_employee_section.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/mainscreen/employee_card_mobile.dart';
import 'package:my_app/screens/device_specific/profile_screen_mobile.dart';

import 'employee_list_screen_mobile.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int _selectedIndex = 0;
  Timer? _liveStatusTimer;

  @override
  void initState() {
    super.initState();
    _liveStatusTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (!mounted) return;
      context.read<AdminDashboardBloc>().add(const AdminDashboardRefreshed());
    });
  }

  @override
  void dispose() {
    _liveStatusTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor:Color(0xFFFAF9F6),
          body: IndexedStack(
            index: _selectedIndex,
            children: [
              _buildHomeTab(state),
              EmployeeListScreenMobile(
                onBack: () => setState(() => _selectedIndex = 0),
              ),
              _buildPlaceholder("Logs"),
              const ProfileScreen(),
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

    final List<Employee> displayList = state.liveEmployees;

    return SafeArea(
      child: Column(
        children: [
          const AdminTopBarMobile(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                context
                    .read<AdminDashboardBloc>()
                    .add(const AdminDashboardRefreshed());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DashboardGrid(
                      employees: displayList,
                      totalEmployeeCount: state.totalEmployeeCount,
                      isSuperuser: state.isSuperuser,
                    ),
                    const SizedBox(height: 24),
                    MobileEmployeeSection(
                      embedded: true,
                      totalEmployeeCount: state.totalEmployeeCount,
                      employees: displayList,
                      onEmployeeTap: (employee) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EmployeeCardMobile(employee: employee),
                          ),
                        );
                      },
                    ),
                  ],
                ),
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