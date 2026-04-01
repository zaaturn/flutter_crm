import 'package:flutter/material.dart';

import '../../../domain/entities/event.dart';
import 'package:my_app/event_management/shared/themes/app_theme.dart';
import 'package:my_app/event_management/shared/themes/event_management_fonts.dart';

import 'event_detail_surface_card.dart';

class EventDetailDescriptionCard extends StatelessWidget {
  final Event event;

  const EventDetailDescriptionCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final desc = event.description.trim();

    return EventDetailSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: EventManagementFonts.detailSectionTitle(),
          ),
          const SizedBox(height: 14),
          Text(
            desc.isEmpty
                ? 'No description added for this event yet.'
                : desc,
            style: EventManagementFonts.bodyReading().copyWith(
                  color: desc.isEmpty
                      ? AppTheme.textHint
                      : AppTheme.textPrimary,
                ),
          ),
        ],
      ),
    );
  }
}
