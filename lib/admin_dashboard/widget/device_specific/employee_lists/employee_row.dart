import 'package:flutter/material.dart';
import 'package:my_app/admin_dashboard/model/employee.dart';
import 'package:my_app/admin_dashboard/utils/app_theme.dart';

class EmployeeRow extends StatelessWidget {
  final Employee employee;
  final VoidCallback? onViewProfile;
  final VoidCallback? onEmail;

  const EmployeeRow({
    super.key,
    required this.employee,
    this.onViewProfile,
    this.onEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: Colors.white,
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            child: Text(employee.initials),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(employee.fullName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold)),
                Text(employee.designation ?? ''),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.mail_outline),
            onPressed: onEmail,
          ),
          ElevatedButton(
            onPressed: onViewProfile,
            child: const Text("View"),
          ),
        ],
      ),
    );
  }
}
