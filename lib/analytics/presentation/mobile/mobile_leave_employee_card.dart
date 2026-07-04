import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/leave_analytics_model.dart';
import '../../theme/analytics_theme.dart';
import 'mobile_attendance_status_style.dart';

class MobileLeaveEmployeeCard extends StatelessWidget {
  const MobileLeaveEmployeeCard({super.key, required this.employee});

  final OnLeaveTodayEmployee employee;

  @override
  Widget build(BuildContext context) {
    final leaveType = _formatLeaveType(employee.leaveType);
    const strip = Color(0xFFB08AA3);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AnalyticsMobileTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ColoredBox(color: strip, child: SizedBox(width: 4)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color(0xFFF3E8EF),
                      child: Text(
                        MobileAttendanceStatusStyle.initials(
                          employee.employeeName,
                        ),
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          color: const Color(0xFF7A4F68),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            employee.employeeName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: AnalyticsMobileTheme.textDark,
                            ),
                          ),
                          if (employee.employeeCode != null &&
                              employee.employeeCode!.trim().isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              employee.employeeCode!.trim(),
                              style: GoogleFonts.manrope(
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                                color: AnalyticsMobileTheme.textMuted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 110),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8EEF4),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: strip.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Text(
                        leaveType,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                          height: 1.2,
                          color: const Color(0xFF7A4F68),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatLeaveType(String? raw) {
    final value = raw?.trim();
    if (value == null || value.isEmpty) return 'Leave';
    return value
        .replaceAll('_', ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }
}
