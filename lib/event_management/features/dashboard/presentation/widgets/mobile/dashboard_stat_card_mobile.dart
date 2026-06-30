import 'package:flutter/material.dart';
import 'package:my_app/event_management/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:my_app/event_management/features/dashboard/shared/dashboard_ui_theme.dart';

class DashboardStatCardsMobile extends StatelessWidget {
  final DashboardState state;

  const DashboardStatCardsMobile({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final todayCount = state.todayEvents.length;
    final upcomingCount = state.upcomingEvents.length;
    final endedCount = state.missedToday.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      child: Row(
        children: [
          _CourseCard(
            label: 'Today',
            count: todayCount,
            tint: const Color(0xFFE8F4FD),
            accent: const Color(0xFF5B9BD5),
            icon: Icons.wb_sunny_rounded,
          ),
          const SizedBox(width: 20),
          _CourseCard(
            label: 'Upcoming',
            count: upcomingCount,
            tint: DashboardUiTheme.statUpcomingLight,
            accent: DashboardUiTheme.statUpcoming,
            icon: Icons.event_available_rounded,
          ),
          const SizedBox(width: 20),
          _CourseCard(
            label: 'Ended',
            count: endedCount,
            tint: endedCount > 0
                ? DashboardUiTheme.statEndedLight
                : const Color(0xFFE8F5E9),
            accent: endedCount > 0
                ? DashboardUiTheme.statEnded
                : DashboardUiTheme.statToday,
            icon: Icons.history_rounded,
          ),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({
    required this.label,
    required this.count,
    required this.tint,
    required this.accent,
    required this.icon,
  });

  final String label;
  final int count;
  final Color tint;
  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 110,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: tint,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accent.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accent, size: 18),
            const Spacer(),
            Text(
              count.toString().padLeft(2, '0'),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: DashboardUiTheme.textDark,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: accent.withValues(alpha: 0.9),
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
