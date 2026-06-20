import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/analytics_theme.dart';
import 'package:my_app/core/widgets/analytics_icons.dart';

class AnalyticsForbiddenView extends StatelessWidget {
  final VoidCallback onBack;

  const AnalyticsForbiddenView({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnalyticsIcon(
                type: AnalyticsIconType.lock,
                size: 56,
                color: AnalyticsDesktopTheme.purple.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 16),
              Text(
                "You don't have access to Analytics",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AnalyticsDesktopTheme.textMain,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You do not have permission to view analytics. '
                'This is separate from a session expiry — try another account '
                'or ask a superadmin to enable the Analytics module.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: AnalyticsDesktopTheme.textMuted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AnalyticsDesktopTheme.purple,
                ),
                onPressed: onBack,
                child: const Text('Go back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
