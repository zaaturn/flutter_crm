import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/admin_dashboard/bloc/admin_dashboard_state.dart';
import 'package:my_app/admin_dashboard/model/employee.dart';
import 'package:my_app/admin_dashboard/shared/admin_dashboard_theme.dart';
import 'package:my_app/core/widgets/app_material_icon.dart';
import 'package:my_app/core/widgets/sidebar_chart_icon.dart';

/// Top analytics-style overview — each metric in its own panel box.
class AdminDashboardOverviewSection extends StatelessWidget {
  final AdminDashboardState state;

  const AdminDashboardOverviewSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final working = state.liveEmployees
        .where((e) => e.liveStatus == LiveStatus.working)
        .length;
    final onBreak = state.liveEmployees
        .where((e) => e.liveStatus == LiveStatus.breakTime)
        .length;
    final loggedIn = state.liveEmployees.length;
    final totalStaff = state.totalEmployeeCount > 0
        ? state.totalEmployeeCount
        : state.liveEmployees.length;
    final openTasks = state.tasks.where((t) {
      final s = t.status.trim().toLowerCase();
      return s == 'pending' || s == 'in_progress' || s == 'in progress';
    }).length;
    final eventsToday = state.events.length;

    const gap = AdminDashboardTheme.panelGap;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AdminDashboardTheme.tealLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const SidebarChartIcon(
                  size: 22,
                  color: AdminDashboardTheme.teal,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Analytics Overview',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AdminDashboardTheme.textDark,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    'Workspace snapshot at a glance',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AdminDashboardTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: AdminDashboardPanel(
                  margin: const EdgeInsets.only(right: gap),
                  child: _OverviewStatBox(
                    label: 'Total Staff',
                    value: '$totalStaff',
                    subtitle: 'Registered employees',
                    icon: Icons.groups_rounded,
                    tint: const Color(0xFFE8F4FD),
                    accent: const Color(0xFF3B82F6),
                  ),
                ),
              ),
              Expanded(
                child: AdminDashboardPanel(
                  margin: const EdgeInsets.only(right: gap),
                  child: _OverviewStatBox(
                    label: 'Logged In',
                    value: '$loggedIn',
                    subtitle: 'Active sessions today',
                    icon: Icons.login_rounded,
                    tint: const Color(0xFFECFDF5),
                    accent: const Color(0xFF10B981),
                  ),
                ),
              ),
              Expanded(
                child: AdminDashboardPanel(
                  margin: const EdgeInsets.only(right: gap),
                  child: _OverviewStatBox(
                    label: 'Working Now',
                    value: '$working',
                    subtitle: onBreak > 0 ? '$onBreak on break' : 'Currently working',
                    icon: Icons.work_outline_rounded,
                    tint: const Color(0xFFF3E8FF),
                    accent: const Color(0xFF7C3AED),
                  ),
                ),
              ),
              Expanded(
                child: AdminDashboardPanel(
                  margin: const EdgeInsets.only(right: gap),
                  child: _OverviewStatBox(
                    label: 'Open Tasks',
                    value: '$openTasks',
                    subtitle: 'Pending & in progress',
                    icon: Icons.task_alt_rounded,
                    tint: const Color(0xFFFFF7ED),
                    accent: const Color(0xFFF59E0B),
                  ),
                ),
              ),
              Expanded(
                child: AdminDashboardPanel(
                  child: _OverviewStatBox(
                    label: 'Events Today',
                    value: '$eventsToday',
                    subtitle: 'Scheduled for today',
                    icon: Icons.event_available_rounded,
                    tint: const Color(0xFFE6F4F1),
                    accent: AdminDashboardTheme.teal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OverviewStatBox extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color tint;
  final Color accent;

  const _OverviewStatBox({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.tint,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(AdminDashboardTheme.panelRadius - 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppMaterialIcon(icon, color: accent, size: 22),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  label.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: AdminDashboardTheme.textDark,
              letterSpacing: -1,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AdminDashboardTheme.textMuted,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
