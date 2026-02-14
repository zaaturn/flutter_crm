import 'package:flutter/material.dart';
import 'package:my_app/admin_dashboard/model/employee.dart';
import 'employee_detail_shared.dart';

class EmployeeEmploymentSection extends StatelessWidget {
  final Employee employee;

  const EmployeeEmploymentSection({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Employment Details',
      icon: Icons.work_outline,
      iconColor: const Color(0xFF8B5CF6),
      children: [
        InfoRow(
          icon: Icons.badge_outlined,
          label: 'Employee ID',
          value: employee.employeeId,
          copyable: true,
        ),
        const CustomDivider(),
        InfoRow(
          icon: Icons.business_center_outlined,
          label: 'Designation',
          value: employee.designation ?? " ",
        ),
        const CustomDivider(),
        InfoRow(
          icon: Icons.domain_outlined,
          label: 'Department',
          value: employee.department ?? " ",
        ),
        const CustomDivider(),
        InfoRow(
          icon: Icons.location_city_outlined,
          label: 'Work Location',
          value: employee.workLocation ?? " ",
        ),
        const CustomDivider(),
        InfoRow(
          icon: Icons.calendar_month_outlined,
          label: 'Date of Joining',
          value: formatDate(employee.dateOfJoining),
        ),
        const CustomDivider(),
        InfoRow(
          icon: Icons.verified_outlined,
          label: 'Status',
          value: employee.isActive ? 'Active' : 'Inactive',
          valueWidget: Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: employee.isActive
                  ? const Color(0xFF10B981).withOpacity(0.1)
                  : const Color(0xFFEF4444).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              employee.isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: employee.isActive
                    ? const Color(0xFF10B981)
                    : const Color(0xFFEF4444),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
