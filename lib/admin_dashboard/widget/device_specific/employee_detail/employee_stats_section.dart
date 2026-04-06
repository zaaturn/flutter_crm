import 'package:flutter/material.dart';
import 'package:my_app/admin_dashboard/model/employee.dart';
// Ensure this import path is correct for your project
import 'package:my_app/admin_dashboard/widget/device_specific/employee_lists/app_theme.dart';
import 'employee_detail_shared.dart';

class EmployeeStatsSection extends StatelessWidget {
  final Employee employee;

  const EmployeeStatsSection({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // ── Joined Date Card ──────────────────────
          Expanded(
            child: _buildStatCard(
              icon: Icons.calendar_today_rounded,
              label: 'Joined Date',
              value: formatJoinDate(employee.dateOfJoining),
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),

          // ── Department/ID Card ────────────────────
          Expanded(
            child: _buildStatCard(
              icon: Icons.badge_outlined,
              label: 'Employee ID',
              value: '#${employee.employeeId ?? "N/A"}',
              color: const Color(0xFF8B5CF6), // A subtle violet to complement purple
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Container with Daxarrow-style tint
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 16),

          // Label text
          Text(
            label,
            style: AppTextStyles.small.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),

          // Value text
          Text(
            value,
            style: AppTextStyles.title.copyWith(
              fontSize: 15,
              color: AppColors.textHeading,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}