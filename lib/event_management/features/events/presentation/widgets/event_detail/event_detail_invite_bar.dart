import 'package:flutter/material.dart';

import '../../../domain/entities/event.dart';
import 'package:my_app/event_management/shared/themes/app_theme.dart';
import 'package:my_app/event_management/shared/themes/event_management_fonts.dart';

/// Accept / decline for pending invites (POST …/accept/, …/decline/).
class EventDetailInviteBar extends StatelessWidget {
  final Event event;
  final bool busy;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const EventDetailInviteBar({
    super.key,
    required this.event,
    required this.busy,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFEEF2FF),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.mail_outline_rounded,
                    color: AppTheme.primaryBlue, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "You're invited to this event. Accept or decline.",
                    style: EventManagementFonts.jakarta(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: busy ? null : onDecline,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    side: const BorderSide(color: AppTheme.borderLight),
                  ),
                  child: Text(
                    'Decline',
                    style: EventManagementFonts.jakarta(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                FilledButton(
                  onPressed: busy ? null : onAccept,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Accept',
                          style: EventManagementFonts.jakarta(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
