import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_app/admin_dashboard/bloc/admin_dashboard_bloc.dart';
import 'package:my_app/admin_dashboard/bloc/admin_dashboard_event.dart';
import 'package:my_app/admin_dashboard/bloc/admin_dashboard_state.dart';

import 'package:my_app/admin_dashboard/sidebar/device_specific/sidebar_widgets_desktop.dart';

import 'package:my_app/admin_dashboard/widget/device_specific/welcome_header_desktop.dart';
import 'package:my_app/admin_dashboard/widget/device_specific/task_section_desktop.dart';
import 'package:my_app/admin_dashboard/widget/device_specific/employee_section_desktop.dart';
import 'package:my_app/admin_dashboard/widget/device_specific/calender_desktop.dart';

class AdminDashboardDesktop extends StatelessWidget {
  const AdminDashboardDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      body: _AdminDashboardDesktopView(),
    );
  }
}

class _AdminDashboardDesktopView extends StatefulWidget {
  const _AdminDashboardDesktopView({super.key});

  @override
  State<_AdminDashboardDesktopView> createState() =>
      _AdminDashboardDesktopViewState();
}

class _AdminDashboardDesktopViewState
    extends State<_AdminDashboardDesktopView> {

  @override
  void initState() {
    super.initState();
    context.read<AdminDashboardBloc>().add(AdminDashboardStarted());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Row(
          children: [
            // ================= LEFT SIDEBAR =================
            DesktopSidebar(
              parentContext: context,
              userName: state.username ?? "Admin",
              userRole: state.role ?? "Super Admin",
            ),

            // ================= CENTER CONTENT =================
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  ModernDashboardHeader(
                    adminName: state.username ?? "Admin",
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 32,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DesktopTaskSectionModern(
                            tasks: state.tasks,
                          ),
                          const SizedBox(height: 32),
                          DesktopEmployeeSection(
                            employees: state.liveEmployees,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ================= RIGHT PANEL (CALENDAR ONLY) =================
            Container(
              width: 360,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  left: BorderSide(color: Colors.grey.shade100),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(24),
                child: DashboardCalendar(),
              ),
            ),
          ],
        );
      },
    );
  }
}
