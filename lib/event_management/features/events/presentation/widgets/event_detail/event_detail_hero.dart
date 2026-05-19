import 'package:flutter/material.dart';

import '../../../domain/entities/event.dart';
import 'package:my_app/event_management/shared/themes/app_theme.dart';
import 'package:my_app/event_management/shared/themes/event_management_fonts.dart';

import 'event_detail_constants.dart';

class EventDetailHero extends StatelessWidget {
  final Event event;
  /// Shown only when the event has a meeting link; opens the link.
  final VoidCallback? onJoinEvent;

  const EventDetailHero({
    super.key,
    required this.event,
    this.onJoinEvent,
  });

  String get _secondaryTag {
    final id = event.id;
    if (id.length >= 4) return id.substring(0, 4).toUpperCase();
    return id.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: EventDetailColors.typePillBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  event.type.label.toUpperCase(),
                  style: EventManagementFonts.chipLabel().copyWith(
                    letterSpacing: 0.85,
                    color: EventDetailColors.typePillFg,
                  ),
                ),
              ),
              Text(
                _secondaryTag,
                style: EventManagementFonts.jakarta(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, c) {
              final narrow = c.maxWidth < 560;
              final titleStyle = EventManagementFonts.detailHeadline();
              final join = _joinButton();
              if (narrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(event.title, style: titleStyle),
                    if (join != null) ...[
                      const SizedBox(height: 16),
                      join,
                    ],
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Text(event.title, style: titleStyle)),
                  if (join != null) ...[
                    const SizedBox(width: 16),
                    join,
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget? _joinButton() {
    if (onJoinEvent == null) return null;
    return FilledButton.icon(
      onPressed: onJoinEvent,
      icon: const Icon(Icons.video_call_rounded, size: 20),
      label: Text(
        'Join Event',
        style: EventManagementFonts.jakarta(
          fontWeight: FontWeight.w700,
          fontSize: 15,
          color: Colors.white,
        ),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: EventDetailColors.primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
