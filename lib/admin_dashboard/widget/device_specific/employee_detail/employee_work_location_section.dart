import 'package:flutter/material.dart';
import 'package:my_app/admin_dashboard/model/employee.dart';
import 'employee_detail_shared.dart';

class EmployeeWorkLocationSection extends StatelessWidget {
  final Employee employee;

  const EmployeeWorkLocationSection(
      {super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Work Location',
      icon: Icons.location_on_outlined,
      iconColor: const Color(0xFFF59E0B),
      children: [
        InfoRow(
          icon: Icons.business_outlined,
          label: 'Office Location',
          value: employee.workLocation ?? " ",
        ),
      ],
    );
  }
}
