import 'package:flutter/material.dart';
import 'package:my_app/admin_dashboard/model/employee.dart';

class EmployeeProfileHeader extends StatelessWidget {
  final Employee employee;

  const EmployeeProfileHeader({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        children: [
          CircleAvatar(
            radius: 52,
            backgroundColor: const Color(0xFFEEF2FF),
            backgroundImage: employee.profilePhoto != null
                ? NetworkImage(employee.profilePhoto!)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            employee.fullName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }
}
