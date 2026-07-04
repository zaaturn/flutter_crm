import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/admin_dashboard/bloc/admin_dashboard_bloc.dart';
import 'package:my_app/admin_dashboard/bloc/admin_dashboard_event.dart';
import 'package:my_app/admin_dashboard/bloc/admin_dashboard_state.dart';
import 'package:my_app/admin_dashboard/presentation/mobile/mobile_dashboard_home_tab.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/widgets/admin_dashboard_widgets/admin_top_bar_mobile.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/widgets/admin_dashboard_widgets/bottom_nav.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/mainscreen/employee_list_screen_mobile.dart';
import 'package:my_app/screens/device_specific/profile_screen_mobile.dart';

/// Mobile admin shell — bottom nav + module grid home tab.
class MobileDashboardShell extends StatefulWidget {
  const MobileDashboardShell({super.key});

  @override
  State<MobileDashboardShell> createState() => _MobileDashboardShellState();
}

class _MobileDashboardShellState extends State<MobileDashboardShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AdminMobileTerracottaTheme.cream,
          extendBody: true,
          body: IndexedStack(
            index: _selectedIndex,
            children: [
              MobileDashboardHomeTab(state: state),
              EmployeeListScreenMobile(
                onBack: () => setState(() => _selectedIndex = 0),
              ),
              _buildPlaceholder('Logs'),
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
