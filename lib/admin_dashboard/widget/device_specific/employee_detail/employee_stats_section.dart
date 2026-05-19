import 'package:flutter/material.dart';
import 'package:my_app/admin_dashboard/model/employee.dart';
import 'package:my_app/admin_dashboard/widget/device_specific/employee_lists/app_theme.dart';
import 'employee_detail_shared.dart';

class EmployeeStatsSection extends StatelessWidget {
  final Employee employee;

  const EmployeeStatsSection({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    
    final String rawId = employee.employeeId?.toString() ?? "N/A";
    final String sanitizedId = rawId.replaceAll(' ', '');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.calendar_today_rounded,
                label: 'Joined Date',
                value: formatJoinDate(employee.dateOfJoining),
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.badge_outlined,
                label: 'Employee ID',
                
                value: sanitizedId,
                color: const Color(0xFF6366F1),
              ),
            ),
          ],
        ),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: AppTextStyles.small.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 11,
              color: AppColors.textHeading.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 2),

   
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
            
              style: AppTextStyles.title.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textHeading,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}