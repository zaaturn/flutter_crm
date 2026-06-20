import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/analytics_theme.dart';

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
            icon: const Icon(Icons.arrow_back_rounded),
            color: AnalyticsDesktopTheme.textMain,
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
            icon: const Icon(Icons.refresh_rounded),
            color: AnalyticsDesktopTheme.purple,
          ),
        ],
      ),
    );
  }
}
