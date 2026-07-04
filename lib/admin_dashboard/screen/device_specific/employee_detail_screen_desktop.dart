import 'package:flutter/material.dart';
import 'package:my_app/admin_dashboard/model/employee.dart';
import 'package:my_app/admin_dashboard/shared/admin_dashboard_theme.dart';

import 'package:my_app/admin_dashboard/widget/device_specific/employee_detail/employee_profile_header.dart';
import 'package:my_app/admin_dashboard/widget/device_specific/employee_detail/employee_stats_section.dart';
import 'package:my_app/admin_dashboard/widget/device_specific/employee_detail/employee_contact_section.dart';
import 'package:my_app/admin_dashboard/widget/device_specific/employee_detail/employee_employment_section.dart';
import 'package:my_app/admin_dashboard/widget/device_specific/employee_detail/employee_personal_section.dart';
import 'package:my_app/admin_dashboard/widget/device_specific/employee_detail/employee_work_location_section.dart';

class ModernEmployeeDetailScreen extends StatelessWidget {
  final Employee employee;

  const ModernEmployeeDetailScreen({
    super.key,
    required this.employee,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminDashboardTheme.shellMint,
      appBar: AppBar(
        backgroundColor: AdminDashboardTheme.shellMint,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AdminDashboardTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Employee Profile',
          style: AdminDashboardTheme.companyTitle().copyWith(fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AdminDashboardTheme.teal),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: AdminDashboardTheme.textDark),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AdminDashboardTheme.shellPadding,
          0,
          AdminDashboardTheme.shellPadding,
          AdminDashboardTheme.shellPadding,
        ),
        child: Column(
          children: [
            /// PROFILE HEADER
            EmployeeProfileHeader(employee: employee),

            const SizedBox(height: AdminDashboardTheme.panelGap),

            /// STATS SECTION
            EmployeeStatsSection(employee: employee),

            const SizedBox(height: 4),

            /// DETAILS SECTIONS
            Column(
              children: [
                /// CONTACT
                EmployeeContactSection(employee: employee),

                const SizedBox(height: 12),

                /// EMPLOYMENT
                EmployeeEmploymentSection(employee: employee),

                const SizedBox(height: 12),

                /// PERSONAL
                EmployeePersonalSection(employee: employee),

                const SizedBox(height: 12),

                /// WORK LOCATION
                EmployeeWorkLocationSection(employee: employee),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
