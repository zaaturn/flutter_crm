import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/analytics_theme.dart';
import 'package:my_app/core/widgets/analytics_icons.dart';

class AnalyticsHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onRefresh;

  const AnalyticsHeader({
    super.key,
    required this.onBack,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AnalyticsDesktopTheme.surface,
      padding: const EdgeInsets.fromLTRB(8, 12, 20, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const AnalyticsIcon(
              type: AnalyticsIconType.arrowBack,
              color: AnalyticsDesktopTheme.textMain,
            ),
          ),
          Text(
            'Analytics',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AnalyticsDesktopTheme.textMain,
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Refresh',
            onPressed: onRefresh,
            icon: const AnalyticsIcon(
              type: AnalyticsIconType.refresh,
              color: AnalyticsDesktopTheme.purple,
            ),
          ),
        ],
      ),
    );
  }
}
