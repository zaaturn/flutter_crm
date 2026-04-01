import 'package:flutter/material.dart';
import 'package:my_app/event_management/features/events/domain/entities/event.dart';
import 'package:my_app/event_management/shared/themes/app_theme.dart';

import 'event_composer_white_card.dart';
import 'event_guest_avatar_row.dart';

/// Repeat, guests, conference link, and location rows.
class EventSettingsCard extends StatelessWidget {
  final String recurrenceLabel;
  final VoidCallback onRepeatTap;
  final List<Participant> participants;
  final VoidCallback onGuestsTap;
  final String meetingLink;
  final VoidCallback onConferenceTap;
  final String location;
  final VoidCallback onLocationTap;

  const EventSettingsCard({
    super.key,
    required this.recurrenceLabel,
    required this.onRepeatTap,
    required this.participants,
    required this.onGuestsTap,
    required this.meetingLink,
    required this.onConferenceTap,
    required this.location,
    required this.onLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    return EventComposerWhiteCard(
      child: Column(
        children: [
          _settingsTile(
            context,
            leading: Icons.repeat_rounded,
            title: 'Repeat',
            trailingText: recurrenceLabel,
            onTap: onRepeatTap,
          ),
          const Divider(height: 1),
          _settingsTile(
            context,
            leading: Icons.person_add_alt_1_outlined,
            title: 'Add Guests',
            customTrailing: EventGuestAvatarRow(participants: participants),
            onTap: onGuestsTap,
          ),
          const Divider(height: 1),
          _settingsTile(
            context,
            leading: Icons.videocam_outlined,
            title: 'Conference Link',
            customTrailing: meetingLink.isEmpty
                ? IconButton(
                    onPressed: onConferenceTap,
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    color: AppTheme.primaryBlue,
                  )
                : ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 160),
                    child: Text(
                      meetingLink,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
            onTap: onConferenceTap,
          ),
          const Divider(height: 1),
          _settingsTile(
            context,
            leading: Icons.location_on_outlined,
            title: 'Location',
            trailingText: location.isEmpty ? 'Add' : location,
            trailingIcon: Icons.map_outlined,
            onTap: onLocationTap,
            truncateTrailing: true,
          ),
        ],
      ),
    );
  }
}

Widget _settingsTile(
  BuildContext context, {
  required IconData leading,
  required String title,
  String? trailingText,
  Widget? customTrailing,
  IconData? trailingIcon,
  VoidCallback? onTap,
  bool truncateTrailing = false,
}) {
  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Row(
        children: [
          Icon(leading, color: AppTheme.textSecondary, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          if (customTrailing != null)
            customTrailing
          else ...[
            Flexible(
              flex: 2,
              child: Text(
                trailingText ?? '',
                textAlign: TextAlign.end,
                overflow: truncateTrailing ? TextOverflow.ellipsis : null,
                maxLines: 1,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 6),
              Icon(trailingIcon, size: 20, color: AppTheme.textSecondary),
            ] else
              Icon(Icons.chevron_right_rounded,
                  color: AppTheme.textHint, size: 22),
          ],
        ],
      ),
    ),
  );
}
