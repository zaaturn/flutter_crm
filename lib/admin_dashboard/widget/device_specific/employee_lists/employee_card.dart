
import 'package:flutter/material.dart';
import 'package:my_app/admin_dashboard/model/employee.dart';
import 'package:my_app/admin_dashboard/widget/device_specific/employee_lists/app_theme.dart';

class EmployeeCard extends StatelessWidget {
  final Employee employee;
  final bool isOnline;
  final VoidCallback? onViewProfile;
  final VoidCallback? onEmail;

  const EmployeeCard({
    super.key,
    required this.employee,
    required this.isOnline,
    this.onViewProfile,
    this.onEmail,
  });

  // Consistant avatar color per employee
  Color get _avatarColor {
    const colors = [
      AppColors.primary,
      Color(0xFF0EA5E9), // Cyan
      AppColors.active, // Green
      Color(0xFFF59E0B), // Amber
      Color(0xFF8B5CF6), // Violet
      AppColors.offline, // Red
    ];
    // Return a color based on the hash of the employee ID for consistency
    return colors[(employee.employeeId?.hashCode ?? 0) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // ── Updated Card Styling ──────────────────
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        // subtle shadow for definition
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── #EMP ID (top-right) ───────────────────
          Align(
            alignment: Alignment.topRight,
            child: Text(
              '#${employee.employeeId ?? ""}',
              style: AppTextStyles.small, // Inherited theme style
            ),
          ),
          const SizedBox(height: 6),

          // ── Avatar + status dot ───────────────────
          _buildAvatarStack(),
          const SizedBox(height: 10),

          // ── Name ─────────────────────────────────
          Text(
            employee.fullName,
            style: AppTextStyles.title, // Inherited theme style
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),

          // ── Designation ───────────────────────────
          Text(
            employee.designation ?? '—',
            style: AppTextStyles.subtitle, // Inherited theme style
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),

          // ── Status badge ──────────────────────────
          _buildStatusBadge(),
          const SizedBox(height: 10),

          // ── Location + Department tags ─────────────
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              if (employee.workLocation?.isNotEmpty == true)
                _Tag(
                  icon: Icons.location_on_outlined,
                  label: employee.workLocation!,
                  color: AppColors.textBody,
                  bg: const Color(0xFFF3F4F6),
                ),
              if (employee.department?.isNotEmpty == true)
                _Tag(
                  icon: Icons.corporate_fare,
                  label: employee.department!,
                  color: AppColors.primary,
                  bg: AppColors.primaryLight,
                ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Action Buttons ────────────────────────
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: ElevatedButton(
                    onPressed: onViewProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      textStyle: AppTextStyles.button,
                    ),
                    child: const Text('View Profile'),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 38,
                width: 38,
                child: OutlinedButton(
                  onPressed: onEmail,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Icon(
                    Icons.mail_outline,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarStack() {
    return Stack(
      children: [
        _buildAvatar(),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              // The dot color should match the badge below
              color: isOnline ? AppColors.active : AppColors.offline,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.cardBg, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    if (employee.profilePhoto?.isNotEmpty == true) {
      return CircleAvatar(
        radius: 28,
        backgroundImage: NetworkImage(employee.profilePhoto!),
        onBackgroundImageError: (_, __) {},
        backgroundColor: _avatarColor.withOpacity(0.12),
      );
    }
    return CircleAvatar(
      radius: 28,
      backgroundColor: _avatarColor.withOpacity(0.12),
      child: Text(
        employee.initials,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: _avatarColor,
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final Color badgeColor = isOnline ? AppColors.active : AppColors.offline;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isOnline ? "Active" : "Logged Out",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
          )
        ],
      ),
    );
  }
}

// ── Tag chip ──────────────────────────────────────────────────────────────────
class _Tag extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color, bg;

  const _Tag({
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}