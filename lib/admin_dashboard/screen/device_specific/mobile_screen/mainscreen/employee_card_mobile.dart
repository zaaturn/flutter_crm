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
      Color(0xFF6366F1),
      Color(0xFF0EA5E9),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFF8B5CF6),
      Color(0xFFEF4444),
    ];
    final int index =
    (employee.employeeId.hashCode);
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final status = employee.liveStatus;

    final bool isWorking = status == LiveStatus.working;
    final bool isOnBreak = status == LiveStatus.breakTime;

    final Color statusColor = isWorking
        ? const Color(0xFF10B981)
        : (isOnBreak
        ? const Color(0xFFF59E0B)
        : const Color(0xFF94A3B8));

    final String statusLabel = employee.statusText;

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
          /// EMPLOYEE ID
          Align(
            alignment: Alignment.topRight,
            child: Text(
              '#${employee.employeeId}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ),

          /// AVATAR + STATUS DOT
          Stack(
            children: [
              _buildAvatar(),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 14,
                  height: 14,
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

          /// NAME
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

          /// DESIGNATION
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

          const SizedBox(height: 8),

          /// 🔥 CHECK-IN + STATUS (LIKE DESKTOP)
          Row(
            children: [
              Icon(Icons.login, size: 14, color: Colors.green),
              const SizedBox(width: 4),
              Text(
                employee.checkIn,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.circle, size: 6, color: statusColor),
              const SizedBox(width: 4),
              Text(
                statusLabel,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// STATUS BADGE
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              statusLabel,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
          ),

          const SizedBox(height: 12),

          /// TAGS
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              if (employee.workLocation?.isNotEmpty == true)
                _Tag(
                  icon: Icons.location_on_outlined,
                  label: employee.workLocation!,
                ),
              if (employee.department?.isNotEmpty == true)
                _Tag(
                  icon: Icons.business_outlined,
                  label: employee.department!,
                ),
            ],
          ),

          const Spacer(),

          /// ACTION BUTTONS
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
                        borderRadius:
                        BorderRadius.circular(8),
                      ),
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
            ? Text(
          employee.initials,
          style: TextStyle(
            color: _avatarColor,
            fontWeight: FontWeight.bold,
          ),
        )
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
      padding:
      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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