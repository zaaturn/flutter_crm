import 'package:flutter/material.dart';
import 'package:my_app/event_management/shared/themes/app_theme.dart';

import '../bloc/dashboard_bloc.dart';

class DashboardStatCards extends StatelessWidget {
  final DashboardState state;

  const DashboardStatCards({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final todayCount = state.todayEvents.length;
    final upcomingCount = state.upcomingEvents.length;
    final endedCount = state.missedEvents.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _StatCard(
            label: 'TODAY',
            count: todayCount,
            accent: AppTheme.primaryBlue,
            icon: Icons.calendar_month_rounded,
            subtitleLeft: todayCount == 1 ? '1 event' : '$todayCount events',
            subtitleRight: 'remaining',
          ),
          const SizedBox(width: 12),
          _StatCard(
            label: 'UPCOMING',
            count: upcomingCount,
            accent: const Color(0xFF7C3AED),
            icon: Icons.redo_rounded,
            subtitleLeft: upcomingCount == 0 ? '+0' : '+$upcomingCount',
            subtitleRight: 'this week',
          ),
          const SizedBox(width: 12),
          _StatCard(
            label: 'ENDED',
            count: endedCount,
            accent: endedCount > 0 ? const Color(0xFFDC2626) : AppTheme.textHint,
            icon: Icons.error_outline_rounded,
            subtitleLeft: 'Requires',
            subtitleRight: 'attention',
            emphasizeRight: endedCount > 0,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color accent;
  final IconData icon;
  final String subtitleLeft;
  final String subtitleRight;
  final bool emphasizeRight;

  const _StatCard({
    required this.label,
    required this.count,
    required this.accent,
    required this.icon,
    required this.subtitleLeft,
    required this.subtitleRight,
    this.emphasizeRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderLight.withValues(alpha: 0.9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    letterSpacing: 1.1,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textHint,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accent, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              count.toString().padLeft(2, '0'),
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.8,
                height: 1,
                color: accent,
              ),
            ),
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
                children: [
                  TextSpan(
                    text: subtitleLeft,
                    style: TextStyle(
                      color: emphasizeRight ? accent : AppTheme.textSecondary,
                    ),
                  ),
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: subtitleRight,
                    style: TextStyle(
                      color: emphasizeRight ? accent : AppTheme.textSecondary,
                      fontWeight: emphasizeRight ? FontWeight.w800 : FontWeight.w600,
                    ),
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

