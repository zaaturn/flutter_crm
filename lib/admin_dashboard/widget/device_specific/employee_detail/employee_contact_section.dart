import 'package:flutter/material.dart';
import 'package:my_app/admin_dashboard/model/employee.dart';
import 'package:my_app/admin_dashboard/shared/admin_dashboard_theme.dart';
import 'employee_detail_shared.dart';

class EmployeeContactSection extends StatelessWidget {
  final Employee employee;

  const EmployeeContactSection({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Contact Information',
      icon: Icons.contact_phone_outlined,
      iconColor: AdminDashboardTheme.teal,
      children: [
        InfoRow(
          icon: Icons.email_outlined,
          label: 'Email',
          value: employee.email,
          copyable: true,
        ),
        const CustomDivider(),
        InfoRow(
          icon: Icons.phone_outlined,
          label: 'Phone',
          value: employee.phoneNumber ?? " ",
          copyable: true,
        ),
        const CustomDivider(),
        InfoRow(
          icon: Icons.alternate_email,
          label: 'Username',
          value: employee.profileUsernameHandle,
        ),
        if (employee.address != null && employee.address!.isNotEmpty) ...[
          const CustomDivider(),
          InfoRow(
            icon: Icons.location_on_outlined,
            label: 'Address',
            value: employee.address!,
            maxLines: 2,
          ),
        ],
      ],
    );
  }
}
