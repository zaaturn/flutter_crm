import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/analytics_bloc.dart';
import '../../bloc/analytics_event.dart';
import '../../bloc/analytics_state.dart';
import '../../theme/analytics_theme.dart';
import 'package:my_app/core/widgets/analytics_icons.dart';

/// Icon-only rail — mirrors the main dashboard's [DesktopSidebar]: no text
/// labels, just icons with a hover tooltip for the name.
class AnalyticsSidebar extends StatelessWidget {
  final VoidCallback onBack;

  const AnalyticsSidebar({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 16, 10, 20),
        child: Column(
          children: [
            _RailButton(
              tooltip: 'Back to dashboard',
              icon: AnalyticsIconType.arrowBack,
              selected: false,
              onTap: onBack,
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AnalyticsDesktopTheme.iconRailBg,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
                  buildWhen: (p, c) => p.tab != c.tab,
                  builder: (context, state) {
                    return Column(
                      children: [
                        _RailButton(
                          tooltip: 'Overview',
                          icon: AnalyticsIconType.overview,
                          selected: state.tab == AnalyticsTab.overview,
                          onTap: () => _go(context, AnalyticsTab.overview),
                        ),
                        _RailButton(
                          tooltip: 'Attendance',
                          icon: AnalyticsIconType.calendar,
                          selected: state.tab == AnalyticsTab.weeklyAttendance,
                          onTap: () =>
                              _go(context, AnalyticsTab.weeklyAttendance),
                        ),
                        _RailButton(
                          tooltip: 'Business',
                          icon: AnalyticsIconType.business,
                          selected: state.tab == AnalyticsTab.weeklyBusiness,
                          onTap: () =>
                              _go(context, AnalyticsTab.weeklyBusiness),
                        ),
                        _RailButton(
                          tooltip: 'Leaves',
                          icon: AnalyticsIconType.leaves,
                          selected: state.tab == AnalyticsTab.leaves,
                          onTap: () => _go(context, AnalyticsTab.leaves),
                        ),
                        _RailButton(
                          tooltip: 'Billing',
                          icon: AnalyticsIconType.receipt,
                          selected: state.tab == AnalyticsTab.monthlyBilling,
                          onTap: () =>
                              _go(context, AnalyticsTab.monthlyBilling),
                        ),
                      ],
                    );
                  },
                ),
              ),
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

class _RailButton extends StatelessWidget {
  final String tooltip;
  final AnalyticsIconType icon;
  final bool selected;
  final VoidCallback onTap;

  const _RailButton({
    required this.tooltip,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        selected ? AnalyticsDesktopTheme.textMain : AnalyticsDesktopTheme.labelMuted;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Tooltip(
        message: tooltip,
        waitDuration: const Duration(milliseconds: 400),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? AnalyticsDesktopTheme.accentYellow
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: AnalyticsIcon(type: icon, size: 22, color: color),
            ),
          ),
        ),
      ),
    );
  }
}
