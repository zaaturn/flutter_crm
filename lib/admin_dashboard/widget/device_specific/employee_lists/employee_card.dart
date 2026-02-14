// lib/admin_dashboard/widgets/employee_card.dart
import 'package:flutter/material.dart';
import 'package:my_app/admin_dashboard/model/employee.dart';
import 'package:my_app/admin_dashboard/utils/app_theme.dart';

class EmployeeCard extends StatelessWidget {
  final Employee employee;
  final VoidCallback? onViewProfile;
  final VoidCallback? onEmail;

  const EmployeeCard({
    super.key,
    required this.employee,
    this.onViewProfile,
    this.onEmail,
  });

  // Consistent avatar color per employee
  Color get _avatarColor {
    const colors = [
      Color(0xFF6366F1), Color(0xFF0EA5E9), Color(0xFF10B981),
      Color(0xFFF59E0B), Color(0xFF8B5CF6), Color(0xFFEF4444),
    ];
    return colors[employee.fullName.length % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── #EMP ID  (top-right) ──────────────────
          Align(
            alignment: Alignment.topRight,
            child: Text(
              '#${employee.employeeId ?? ""}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),
          const SizedBox(height: 4),

          // ── Avatar + status dot ───────────────────
          Stack(
            children: [
              _buildAvatar(),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: employee.statusColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ── Name ─────────────────────────────────
          Text(
            employee.fullName,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),

          // ── Designation ───────────────────────────
          Text(
            employee.designation ?? '—',
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 7),

          // ── Status badge ──────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: employee.statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: employee.statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  employee.statusText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: employee.statusColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 9),

          // ── Location + Department tags ─────────────
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              if (employee.workLocation?.isNotEmpty == true)
                _Tag(
                  icon: Icons.location_on,
                  label: employee.workLocation!,
                  color: AppColors.primary,
                  bg: const Color(0xFFEFF6FF),
                ),
              if (employee.department?.isNotEmpty == true)
                _Tag(
                  icon: Icons.work_outline,
                  label: employee.department!,
                  color: const Color(0xFF64748B),
                  bg: const Color(0xFFF1F5F9),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // ── View Profile + Mail ───────────────────
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 34,
                  child: ElevatedButton(
                    onPressed: onViewProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                      textStyle: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    child: const Text('View Profile'),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 34,
                width: 34,
                child: OutlinedButton(
                  onPressed: onEmail,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                  child: const Icon(
                    Icons.mail_outline,
                    size: 16,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (employee.profilePhoto?.isNotEmpty == true) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(employee.profilePhoto!),
        onBackgroundImageError: (_, __) {},
        backgroundColor: _avatarColor.withOpacity(0.15),
      );
    }
    return CircleAvatar(
      radius: 24,
      backgroundColor: _avatarColor.withOpacity(0.15),
      child: Text(
        employee.initials,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: _avatarColor,
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}