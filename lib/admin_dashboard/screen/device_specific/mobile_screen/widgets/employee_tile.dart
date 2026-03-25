import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/admin_dashboard/model/employee.dart';
import 'avatar.dart';

class EmployeeTile extends StatelessWidget {
  final Employee employee;
  final VoidCallback? onTap;

  const EmployeeTile({
    super.key,
    required this.employee,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    /// ✅ USE MODEL (SAME AS DESKTOP)
    final Color statusColor = employee.statusColor;
    final String statusText = employee.statusText;

    final bool isWorking = employee.liveStatus == LiveStatus.working;
    final bool isOnBreak = employee.liveStatus == LiveStatus.breakTime;

    final String displayName = employee.name.isNotEmpty
        ? employee.name
        : (employee.fullName.isNotEmpty
        ? employee.fullName
        : "Employee #${employee.id}");

    /// 🔍 DEBUG
    print("👤 $displayName → ${employee.liveStatus}");

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                /// AVATAR + STATUS DOT
                Stack(
                  children: [
                    Avatar(employee: employee),
                    Positioned(
                      bottom: 0,
                      right: 0,
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

                const SizedBox(width: 16),

                /// DETAILS
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        "${employee.designation ?? 'Staff'} • ${employee.department ?? 'General'}",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// ✅ TIME + STATUS FIXED
                      Row(
                        children: [
                          Icon(
                            isWorking
                                ? Icons.login_rounded
                                : Icons.history_rounded,
                            size: 14,
                            color: isWorking
                                ? const Color(0xFF10B981)
                                : const Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 6),

                          Text(
                            employee.liveStatus == LiveStatus.working
                                ? "In: ${employee.checkIn}"
                                : (employee.checkOut == '-'
                                ? "Active"
                                : "Last Seen: ${employee.checkOut}"),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                /// STATUS CHIP
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusText.toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}