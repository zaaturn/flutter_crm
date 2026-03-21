import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/admin_dashboard/model/employee.dart';

class EmployeeCardMobile extends StatelessWidget {
  final Employee employee;
  final VoidCallback? onViewProfile;
  final VoidCallback? onEmail;

  const EmployeeCardMobile({
    super.key,
    required this.employee,
    this.onViewProfile,
    this.onEmail,
  });

  Color get _avatarColor {
    const colors = [
      Color(0xFF6366F1), Color(0xFF0EA5E9), Color(0xFF10B981),
      Color(0xFFF59E0B), Color(0xFF8B5CF6), Color(0xFFEF4444),
    ];
    final int index =
    (employee.employeeId?.hashCode ?? employee.fullName.length);
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    // ✅ USE MODEL DIRECTLY (same as desktop)
    final status = employee.liveStatus;

    final bool isWorking = status == LiveStatus.working;
    final bool isOnBreak = status == LiveStatus.breakTime;

    final Color statusColor = isWorking
        ? const Color(0xFF10B981)
        : (isOnBreak ? const Color(0xFFF59E0B) : const Color(0xFF94A3B8));

    final String statusLabel = isWorking
        ? "Working"
        : (isOnBreak ? "On Break" : "Logged Out");

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Text(
              '#${employee.employeeId ?? "N/A"}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ),

          Stack(
            children: [
              _buildAvatar(),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Text(
            employee.fullName,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          Text(
            employee.designation ?? '—',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration:
                  BoxDecoration(color: statusColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(
                  statusLabel,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              if (employee.workLocation?.isNotEmpty == true)
                _Tag(
                    icon: Icons.location_on_outlined,
                    label: employee.workLocation!),
              if (employee.department?.isNotEmpty == true)
                _Tag(
                    icon: Icons.business_outlined,
                    label: employee.department!),
            ],
          ),

          const Spacer(),

          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: onViewProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007AFF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      'View Profile',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _IconButton(icon: Icons.mail_outline, onTap: onEmail),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    bool hasImage =
        employee.profilePhoto != null && employee.profilePhoto!.isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
      ),
      child: CircleAvatar(
        radius: 26,
        backgroundColor: _avatarColor.withOpacity(0.1),
        backgroundImage:
        hasImage ? NetworkImage(employee.profilePhoto!) : null,
        child: !hasImage
            ? Text(employee.initials,
            style: TextStyle(
                color: _avatarColor, fontWeight: FontWeight.bold))
            : null,
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _IconButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      width: 36,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 18, color: const Color(0xFF64748B)),
        onPressed: onTap,
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Tag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}