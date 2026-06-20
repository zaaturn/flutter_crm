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
    const Color terracotta = Color(0xFFB35A38);
    const Color darkSlate = Color(0xFF0F172A);
    const Color midCream = Color(0xFFEBDDCF);

    final String displayName = employee.displayName;

    final Color statusBg = switch (employee.liveStatus) {
      LiveStatus.working => const Color(0xFFDCFCE7),
      LiveStatus.breakTime => const Color(0xFFFEF3C7),
      LiveStatus.loggedOut => const Color(0xFFFEE2E2),
    };
    final Color statusTextColor = switch (employee.liveStatus) {
      LiveStatus.working => const Color(0xFF166534),
      LiveStatus.breakTime => const Color(0xFF92400E),
      LiveStatus.loggedOut => const Color(0xFF991B1B),
    };
    final Color dotColor = switch (employee.liveStatus) {
      LiveStatus.working => const Color(0xFF10B981),
      LiveStatus.breakTime => const Color(0xFFF59E0B),
      LiveStatus.loggedOut => const Color(0xFFEF4444),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: midCream,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: darkSlate.withOpacity(0.15), width: 1.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Avatar(employee: employee, radius: 26),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: midCream, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          displayName,
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: darkSlate,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          employee.statusText.toUpperCase(),
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: statusTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${employee.designation ?? 'Staff'} • ${employee.department ?? 'General'}",
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: darkSlate.withOpacity(0.6),
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.login_rounded,
                        size: 14,
                        color: terracotta,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "In: ${employee.checkIn == '-' ? '--:--' : employee.checkIn}",
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: darkSlate,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}