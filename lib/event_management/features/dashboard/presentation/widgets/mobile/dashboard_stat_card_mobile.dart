import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/event_management/features/dashboard/presentation/bloc/dashboard_bloc.dart';

class ZaaturnMobileUI {
  static const Color background = Color(0xFFFAF3E0); // Light Cream
  static const Color todayGreen = Color(0xFF8AC926);
  static const Color upcomingYellow = Color(0xFFFFCA3A);
  static const Color endedRed = Color(0xFFFF595E);
  static const Color textDark = Color(0xFF1A1A1A);
}

class DashboardStatCardsMobile extends StatelessWidget {
  final DashboardState state;

  const DashboardStatCardsMobile({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final todayCount = state.todayEvents.length;
    final upcomingCount = state.upcomingEvents.length;

    // Logic: Calculate ended events ONLY for today's date
    final endedTodayCount = state.missedEvents.where((e) {
      return e.startTime.year == now.year &&
          e.startTime.month == now.month &&
          e.startTime.day == now.day;
    }).length;

    return Container(
      color: ZaaturnMobileUI.background,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _StatBox(
            label: 'TODAY',
            count: todayCount,
            color: ZaaturnMobileUI.todayGreen,
            icon: Icons.calendar_today_rounded,
          ),
          const SizedBox(width: 10),
          _StatBox(
            label: 'UPCOMING',
            count: upcomingCount,
            color: ZaaturnMobileUI.upcomingYellow,
            icon: Icons.arrow_forward_rounded,
          ),
          const SizedBox(width: 10),
          _StatBox(
            label: 'ENDED',
            count: endedTodayCount,
            color: ZaaturnMobileUI.endedRed,
            icon: Icons.event_busy_rounded,
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _StatBox({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const Spacer(),
            Text(
              count.toString().padLeft(2, '0'),
              style: GoogleFonts.manrope(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Colors.white.withOpacity(0.9),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}