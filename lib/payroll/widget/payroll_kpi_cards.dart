import 'package:flutter/material.dart';

import 'package:my_app/analytics/presentation/widgets/analytics_compact_stat_card.dart';
import 'package:my_app/analytics/theme/analytics_theme.dart';

import '../models/payroll_dashboard_model.dart';

/// Colorful KPI tiles — matches the Analytics Overview tab's stat cards.
class PayrollKpiCards extends StatelessWidget {
  const PayrollKpiCards({super.key, required this.dashboard});

  final PayrollDashboardModel dashboard;

  @override
  Widget build(BuildContext context) {
    final int eligible =
        dashboard.totalEligibleUsers ?? dashboard.totalEmployees;
    final int displayHeadcount = (eligible == 0)
        ? (dashboard.paidRecordsCount + dashboard.totalPending)
        : eligible;
    final int pendingCount = dashboard.unsetCount ?? dashboard.totalPending;

    final tiles = <({String label, String value, Color color})>[
      (
        label: 'Total Headcount',
        value: '$displayHeadcount',
        color: AnalyticsOverviewPalette.mutedTeal,
      ),
      (
        label: 'Total Paid',
        value: '${dashboard.paidRecordsCount}',
        color: AnalyticsOverviewPalette.sageGreen,
      ),
      (
        label: 'Unset / Pending',
        value: '$pendingCount',
        color: AnalyticsOverviewPalette.mustard,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isLarge = constraints.maxWidth > 900;

        final cards = [
          for (final tile in tiles)
            SizedBox(
              height: 96,
              child: AnalyticsCompactStatCard(
                label: tile.label,
                value: tile.value,
                background: tile.color,
              ),
            ),
        ];

        return isLarge
            ? Row(
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    if (i > 0) const SizedBox(width: 16),
                    Expanded(child: cards[i]),
                  ],
                ],
              )
            : Column(
                children: [
                  for (final card in cards)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: card,
                    ),
                ],
              );
      },
    );
  }
}
