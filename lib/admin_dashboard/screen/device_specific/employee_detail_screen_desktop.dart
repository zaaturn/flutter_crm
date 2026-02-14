import 'package:flutter/material.dart';
import 'package:my_app/admin_dashboard/model/employee.dart';

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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Employee Profile',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF6366F1)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF1A1A1A)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// PROFILE HEADER
            EmployeeProfileHeader(employee: employee),

            /// STATS SECTION
            EmployeeStatsSection(employee: employee),

            const SizedBox(height: 16),

            /// DETAILS SECTIONS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
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

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
