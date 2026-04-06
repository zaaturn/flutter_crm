import 'package:flutter/material.dart';
import 'package:my_app/admin_dashboard/model/employee.dart';
import 'package:my_app/admin_dashboard/widget/device_specific/employee_lists/app_theme.dart';

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

  Color get _avatarColor {
    const colors = [
      AppColors.primary,
      Color(0xFF0EA5E9),
      AppColors.active,
      Color(0xFFF59E0B),
      Color(0xFF8B5CF6),
    ];
    return colors[(employee.fullName.length) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Avatar ────────────────────────────────
          CircleAvatar(
            radius: 22,
            backgroundColor: _avatarColor.withOpacity(0.12),
            child: Text(
              employee.initials,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _avatarColor,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // ── Name & Designation ────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.fullName,
                  style: AppTextStyles.title.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  employee.designation ?? 'No Designation',
                  style: AppTextStyles.subtitle,
                ),
              ],
            ),
          ),

          // ── Action Buttons ────────────────────────
          SizedBox(
            height: 36,
            width: 36,
            child: OutlinedButton(
              onPressed: onEmail,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Icon(
                Icons.mail_outline,
                size: 18,
                color: AppColors.textBody,
              ),
            ),
          ),
          const SizedBox(width: 12),

          SizedBox(
            height: 36,
            child: ElevatedButton(
              onPressed: onViewProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "View",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}