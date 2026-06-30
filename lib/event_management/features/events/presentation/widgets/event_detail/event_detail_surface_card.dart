import 'package:flutter/material.dart';

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
    // Flat layout: no white card container; content sits on page surface.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
      decoration: backgroundColor == null
          ? null
          : BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(EventDetailLayout.cardRadius),
            ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: child,
      ),
    );
  }
}
