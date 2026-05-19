import 'package:flutter/material.dart';
import 'package:my_app/event_management/shared/themes/app_theme.dart';

import 'event_detail_constants.dart';

class EventDetailSurfaceCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const EventDetailSurfaceCard({
    super.key,
    required this.child,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(EventDetailLayout.cardRadius),
        border: Border.all(color: AppTheme.borderLight.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
