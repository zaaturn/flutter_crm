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

    final todayCaption =
        todayCount == 1 ? '1 event remaining' : '$todayCount events remaining';
    final upcomingCaption =
        upcomingCount == 0 ? '+0 this week' : '+$upcomingCount this week';
    final endedCaption = 'Requires attention';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SizedBox(
        height: 132,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StatCard(
              label: 'TODAY',
              count: todayCount,
              accent: AppTheme.primaryBlue,
              icon: Icons.calendar_month_rounded,
              caption: todayCaption,
            ),
            const SizedBox(width: 12),
            _StatCard(
              label: 'UPCOMING',
              count: upcomingCount,
              accent: const Color(0xFF7C3AED),
              icon: Icons.redo_rounded,
              caption: upcomingCaption,
            ),
            const SizedBox(width: 12),
            _StatCard(
              label: 'ENDED',
              count: endedCount,
              accent: endedCount > 0 ? const Color(0xFFDC2626) : AppTheme.textHint,
              icon: Icons.error_outline_rounded,
              caption: endedCaption,
              emphasizeCaption: endedCount > 0,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color accent;
  final IconData icon;
  final String caption;
  final bool emphasizeCaption;

  const _StatCard({
    required this.label,
    required this.count,
    required this.accent,
    required this.icon,
    required this.caption,
    this.emphasizeCaption = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, c) {
          final compactW = c.maxWidth < 108;
          final padH = compactW ? 10.0 : 14.0;
          final padVTop = compactW ? 10.0 : 14.0;
          final padVBottom = compactW ? 8.0 : 12.0;
          final iconBox = compactW ? 26.0 : 32.0;
          final iconSize = compactW ? 15.0 : 18.0;
          final labelSize = compactW ? 9.5 : 11.0;
          final countSize = compactW ? 26.0 : 32.0;
          final captionSize = compactW ? 10.5 : 11.5;

          return Container(
            padding: EdgeInsets.fromLTRB(padH, padVTop, padH, padVBottom),
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
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          letterSpacing: 0.9,
                          fontSize: labelSize,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textHint,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: iconBox,
                      height: iconBox,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: accent, size: iconSize),
                    ),
                  ],
                ),
                SizedBox(height: compactW ? 4 : 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    count.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontSize: countSize,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                      height: 1,
                      color: accent,
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      caption,
                      maxLines: 3,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      textHeightBehavior: const TextHeightBehavior(
                        applyHeightToFirstAscent: false,
                        applyHeightToLastDescent: false,
                      ),
                      style: TextStyle(
                        fontSize: captionSize,
                        height: 1.25,
                        fontWeight: emphasizeCaption ? FontWeight.w800 : FontWeight.w600,
                        color: emphasizeCaption ? accent : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
