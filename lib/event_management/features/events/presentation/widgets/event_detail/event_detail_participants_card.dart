import 'package:flutter/material.dart';

import '../../../domain/entities/event.dart';
import 'package:my_app/event_management/shared/themes/app_theme.dart';
import 'package:my_app/event_management/shared/themes/event_management_fonts.dart';

import 'event_detail_constants.dart';
import 'event_detail_surface_card.dart';

class EventDetailParticipantsCard extends StatelessWidget {
  final List<Participant> participants;

  const EventDetailParticipantsCard({
    super.key,
    required this.participants,
  });

  @override
  Widget build(BuildContext context) {
    return EventDetailSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Participants',
            style: EventManagementFonts.detailSectionTitle(),
          ),
          const SizedBox(height: 6),
          if (participants.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'No participants on this event.',
                style: EventManagementFonts.bodyReading().copyWith(
                      color: AppTheme.textHint,
                      fontSize: 14,
                    ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: participants.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: AppTheme.borderLight.withValues(alpha: 0.7),
              ),
              itemBuilder: (context, i) =>
                  _ParticipantRow(participant: participants[i]),
            ),
        ],
      ),
    );
  }
}

class _ParticipantRow extends StatelessWidget {
  final Participant participant;

  const _ParticipantRow({required this.participant});

  @override
  Widget build(BuildContext context) {
    final status = participant.status.toLowerCase();
    late final IconData statusIcon;
    late final Color statusColor;
    if (status == 'accepted') {
      statusIcon = Icons.check_circle_rounded;
      statusColor = const Color(0xFF16A34A);
    } else if (status == 'declined') {
      statusIcon = Icons.cancel_rounded;
      statusColor = const Color(0xFFDC2626);
    } else {
      statusIcon = Icons.schedule_rounded;
      statusColor = AppTheme.textHint;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _avatar(),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participant.username,
                  style: EventManagementFonts.jakarta(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _roleLabel(status),
                  style: EventManagementFonts.jakarta(
                        fontSize: 12.5,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          Icon(statusIcon, color: statusColor, size: 22),
        ],
      ),
    );
  }

  String _roleLabel(String status) {
    return switch (status) {
      'accepted' => 'Confirmed',
      'declined' => 'Declined',
      _ => 'Pending',
    };
  }

  /// [CircleAvatar] forbids `onBackgroundImageError` when `backgroundImage` is null.
  Widget _avatar() {
    final url = participant.avatar?.trim();
    final initial = participant.username.isNotEmpty
        ? participant.username[0].toUpperCase()
        : '?';
    if (url != null && url.isNotEmpty) {
      return CircleAvatar(
        radius: 22,
        backgroundColor: AppTheme.borderLight,
        backgroundImage: NetworkImage(url),
        onBackgroundImageError: (_, __) {},
      );
    }
    return CircleAvatar(
      radius: 22,
      backgroundColor: AppTheme.borderLight,
      child: Text(
        initial,
        style: EventManagementFonts.jakarta(
          fontWeight: FontWeight.w800,
          color: EventDetailColors.primaryBlue,
        ),
      ),
    );
  }
}
