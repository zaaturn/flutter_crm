import 'package:flutter/material.dart';

import '../../shared/dashboard_ui_theme.dart';
import '../bloc/dashboard_bloc.dart';

class DashboardStatCards extends StatelessWidget {
  final DashboardState state;

  const DashboardStatCards({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final todayCount = state.todayEvents.length;
    final upcomingCount = state.upcomingEvents.length;
    final endedCount = state.missedToday.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 28, 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CourseCard(
                  label: 'Today',
                  title: '$todayCount Events',
                  subtitle: todayCount == 1
                      ? '1 on your schedule'
                      : '$todayCount on your schedule',
                  tint: const Color(0xFFE8F4FD),
                  accent: const Color(0xFF5B9BD5),
                  icon: Icons.wb_sunny_rounded,
                  footerLabel: 'Status',
                  footerValue: todayCount > 0 ? 'Active' : 'Clear',
                ),
                const SizedBox(width: 32),
                _CourseCard(
                  label: 'Upcoming',
                  title: '$upcomingCount Events',
                  subtitle: 'This week ahead',
                  tint: DashboardUiTheme.statUpcomingLight,
                  accent: DashboardUiTheme.statUpcoming,
                  icon: Icons.event_available_rounded,
                  footerLabel: 'Queued',
                  footerValue: '+$upcomingCount',
                ),
                const SizedBox(width: 32),
                _CourseCard(
                  label: 'Ended',
                  title: endedCount.toString().padLeft(2, '0'),
                  subtitle: endedCount > 0
                      ? 'Needs review today'
                      : 'All clear today',
                  tint: endedCount > 0
                      ? DashboardUiTheme.statEndedLight
                      : const Color(0xFFE8F5E9),
                  accent: endedCount > 0
                      ? DashboardUiTheme.statEnded
                      : DashboardUiTheme.statToday,
                  icon: Icons.history_rounded,
                  footerLabel: 'Today',
                  footerValue: endedCount > 0 ? 'Review' : 'Done',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({
    required this.label,
    required this.title,
    required this.subtitle,
    required this.tint,
    required this.accent,
    required this.icon,
    required this.footerLabel,
    required this.footerValue,
  });

  final String label;
  final String title;
  final String subtitle;
  final Color tint;
  final Color accent;
  final IconData icon;
  final String footerLabel;
  final String footerValue;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: tint,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accent.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accent, size: 22),
            const SizedBox(height: 16),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: accent.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: DashboardUiTheme.textDark,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: DashboardUiTheme.textMuted.withValues(alpha: 0.95),
              ),
            ),
            const Spacer(),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  footerLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: DashboardUiTheme.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  footerValue,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
