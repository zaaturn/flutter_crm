import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../bloc/analytics_bloc.dart';
import '../../bloc/analytics_event.dart';
import '../../bloc/analytics_state.dart';
import '../../theme/analytics_theme.dart';

class AnalyticsSidebar extends StatelessWidget {
  final VoidCallback onBack;

  const AnalyticsSidebar({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AnalyticsDesktopTheme.sidebarWidth,
      decoration: const BoxDecoration(
        color: AnalyticsDesktopTheme.surface,
        border: Border(
          right: BorderSide(color: AnalyticsDesktopTheme.border),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back_rounded, size: 20),
                    color: AnalyticsDesktopTheme.textMuted,
                  ),
                  Text(
                    'Analytics',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AnalyticsDesktopTheme.textMain,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
            BlocBuilder<AnalyticsBloc, AnalyticsState>(
              buildWhen: (p, c) => p.tab != c.tab,
              builder: (context, state) {
                return Column(
                  children: [
                    _NavItem(
                      icon: Icons.dashboard_outlined,
                      label: 'Overview',
                      selected: state.tab == AnalyticsTab.overview,
                      onTap: () => _go(context, AnalyticsTab.overview),
                    ),
                    _NavItem(
                      icon: Icons.calendar_month_outlined,
                      label: 'Attendance',
                      selected: state.tab == AnalyticsTab.weeklyAttendance,
                      onTap: () => _go(context, AnalyticsTab.weeklyAttendance),
                    ),
                    _NavItem(
                      icon: Icons.trending_up,
                      label: 'Business',
                      selected: state.tab == AnalyticsTab.weeklyBusiness,
                      onTap: () => _go(context, AnalyticsTab.weeklyBusiness),
                    ),
                    _NavItem(
                      icon: Icons.beach_access,
                      label: 'Leaves',
                      selected: state.tab == AnalyticsTab.leaves,
                      onTap: () => _go(context, AnalyticsTab.leaves),
                    ),
                    _NavItem(
                      icon: Icons.receipt_long_outlined,
                      label: 'Billing',
                      selected: state.tab == AnalyticsTab.monthlyBilling,
                      onTap: () => _go(context, AnalyticsTab.monthlyBilling),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _go(BuildContext context, AnalyticsTab tab) {
    context.read<AnalyticsBloc>().add(AnalyticsTabChanged(tab));
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: selected ? AnalyticsDesktopTheme.purpleLight : Colors.transparent,
        borderRadius: BorderRadius.circular(AnalyticsDesktopTheme.controlRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AnalyticsDesktopTheme.controlRadius),
          splashColor: AnalyticsDesktopTheme.purple.withValues(alpha: 0.12),
          highlightColor: AnalyticsDesktopTheme.purpleLight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: selected
                      ? AnalyticsDesktopTheme.purple
                      : AnalyticsDesktopTheme.textMuted,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? AnalyticsDesktopTheme.purpleDark
                          : AnalyticsDesktopTheme.textMain,
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
