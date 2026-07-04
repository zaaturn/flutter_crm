import 'package:flutter/material.dart';
import 'package:my_app/admin_dashboard/model/employee.dart';
import 'package:my_app/admin_dashboard/shared/admin_dashboard_theme.dart';

class EmployeeProfileHeader extends StatelessWidget {
  final Employee employee;

  const EmployeeProfileHeader({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AdminDashboardTheme.surface,
        borderRadius: BorderRadius.circular(AdminDashboardTheme.panelRadius),
        border: Border.all(color: AdminDashboardTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      child: Column(
        children: [
          CircleAvatar(
            radius: 52,
            backgroundColor: AdminDashboardTheme.tealLight,
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
              color: AdminDashboardTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
