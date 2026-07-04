import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/weekly_attendance_model.dart';
import '../../theme/analytics_theme.dart';
import '../../utils/analytics_hours.dart';
import '../../utils/analytics_time.dart';
import 'mobile_attendance_status_style.dart';

class MobileAttendanceEmployeeCard extends StatelessWidget {
  const MobileAttendanceEmployeeCard({super.key, required this.row});

  final WeeklyAttendanceDayRow row;

  @override
  Widget build(BuildContext context) {
    final status = MobileAttendanceStatusStyle.look(
      status: row.status,
      onLeave: row.onLeave,
    );
    final hours = AnalyticsHours.format(row.cappedHours);
    final checkIn = AnalyticsTime.format24(row.checkIn);
    final checkOut = AnalyticsTime.format24(row.checkOut);
    final code = row.employeeCode?.trim();
    final subtitle = _subtitle(code, checkIn, checkOut, status.label);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            Container(width: 4, color: status.strip),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color(0xFFF8E8E4),
                      child: Text(
                        MobileAttendanceStatusStyle.initials(row.employeeName),
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          color: AnalyticsMobileTheme.terracottaDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            row.employeeName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: AnalyticsMobileTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                              height: 1.25,
                              color: AnalyticsMobileTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          hours,
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            color: AnalyticsMobileTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: status.badgeBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status.label,
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w800,
                              fontSize: 9,
                              letterSpacing: 0.3,
                              color: status.badgeFg,
                            ),
                          ),
                        ),
                      ],
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

  String _subtitle(
    String? code,
    String? checkIn,
    String? checkOut,
    String statusLabel,
  ) {
    final idPart = (code != null && code.isNotEmpty) ? code : '—';
    if (statusLabel == 'ABSENT') {
      return '$idPart · No check-in';
    }
    if (checkIn != null && checkOut != null) {
      return '$idPart · $checkIn → $checkOut';
    }
    if (checkIn != null) {
      return '$idPart · $checkIn';
    }
    return idPart;
  }
}
