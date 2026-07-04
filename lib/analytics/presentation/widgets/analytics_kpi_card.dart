import 'package:flutter/material.dart';

import '../../theme/analytics_theme.dart';
import 'package:my_app/core/widgets/analytics_icons.dart';

class AnalyticsKpiCard extends StatelessWidget {
  final String label;
  final String value;
  final AnalyticsIconType icon;
  final Color? accent;
  final bool mobile;

  const AnalyticsKpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.accent,
    this.mobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = accent ??
        (mobile ? AnalyticsMobileTheme.terracotta : AnalyticsDesktopTheme.purple);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: mobile ? AnalyticsMobileTheme.card : AnalyticsDesktopTheme.surface,
        borderRadius: BorderRadius.circular(AnalyticsDesktopTheme.cardRadius),
        border: Border.all(
          color: mobile ? AnalyticsMobileTheme.border : AnalyticsDesktopTheme.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: AnalyticsIcon(type: icon, color: color, size: 20),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AnalyticsDesktopTheme.titleLg.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(label, style: AnalyticsDesktopTheme.bodySm),
        ],
      ),
    );
  }
}
