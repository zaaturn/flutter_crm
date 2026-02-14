import 'package:flutter/material.dart';
import 'package:my_app/admin_dashboard/model/employee.dart';
import 'employee_detail_shared.dart';

class EmployeePersonalSection extends StatelessWidget {
  final Employee employee;

  const EmployeePersonalSection({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Personal Information',
      icon: Icons.person_outline,
      iconColor: const Color(0xFFEC4899),
      children: [
        InfoRow(
          icon: Icons.person_outlined,
          label: 'Full Name',
          value: employee.fullName,
        ),
        const CustomDivider(),
        InfoRow(
          icon: Icons.person_pin_outlined,
          label: 'First Name',
          value: employee.firstName,
        ),
        const CustomDivider(),
        InfoRow(
          icon: Icons.person_pin_outlined,
          label: 'Last Name',
          value: employee.lastName,
        ),
        if (employee.dateOfBirth != null &&
            employee.dateOfBirth!.isNotEmpty) ...[
          const CustomDivider(),
          InfoRow(
            icon: Icons.cake_outlined,
            label: 'Date of Birth',
            value: formatDate(employee.dateOfBirth),
          ),
        ],
      ],
    );
  }
}
