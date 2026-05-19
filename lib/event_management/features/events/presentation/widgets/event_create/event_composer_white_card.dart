import 'package:flutter/material.dart';
import 'package:my_app/event_management/shared/themes/app_theme.dart';

/// Rounded white panel with light border and shadow used across the composer.
class EventComposerWhiteCard extends StatelessWidget {
  final Widget child;

  const EventComposerWhiteCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
