import 'package:flutter/material.dart';

import 'package:my_app/event_management/features/dashboard/shared/dashboard_ui_theme.dart';

/// Flat section wrapper — content sits on page surface (no white card).
class EventComposerWhiteCard extends StatelessWidget {
  final Widget child;

  const EventComposerWhiteCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: child,
    );
  }
}

class EventComposerSectionDivider extends StatelessWidget {
  const EventComposerSectionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Divider(
        height: 1,
        color: DashboardUiTheme.border.withValues(alpha: 0.55),
      ),
    );
  }
}
