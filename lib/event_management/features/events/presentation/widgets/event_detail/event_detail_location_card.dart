import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../domain/entities/event.dart';
import 'package:my_app/event_management/shared/themes/app_theme.dart';
import 'package:my_app/event_management/shared/themes/event_management_fonts.dart';

import 'event_detail_constants.dart';
import 'event_detail_surface_card.dart';

/// Physical address or video meeting link (whichever the event has).
class EventDetailLocationCard extends StatelessWidget {
  final Event event;

  const EventDetailLocationCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final loc = event.location?.trim() ?? '';
    final link = event.meetingLink?.trim() ?? '';

    if (loc.isEmpty && link.isEmpty) {
      return EventDetailSurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header('Location'),
            const SizedBox(height: 16),
            Text(
              'No location or meeting link on this event.',
              style: EventManagementFonts.bodyReading().copyWith(
                    color: AppTheme.textHint,
                    fontSize: 14,
                  ),
            ),
          ],
        ),
      );
    }

    final isMeetingPrimary = link.isNotEmpty && loc.isEmpty;

    return EventDetailSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(
            isMeetingPrimary ? 'Meeting link' : 'Location',
            icon: isMeetingPrimary ? Icons.videocam_outlined : Icons.pin_drop_outlined,
          ),
          const SizedBox(height: 16),
          if (!isMeetingPrimary) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  color: const Color(0xFFE5E7EB),
                  child: const Center(
                    child: Icon(
                      Icons.location_pin,
                      size: 48,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              loc.split(',').first.trim().isEmpty ? 'Location' : loc.split(',').first.trim(),
              style: EventManagementFonts.jakarta(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              loc,
              style: EventManagementFonts.bodyReading().copyWith(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
            ),
          ] else ...[
            Material(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () => _open(link),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.video_call_rounded,
                          color: EventDetailColors.primaryBlue, size: 28),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Join meeting',
                              style: EventManagementFonts.jakarta(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              link,
                              style: EventManagementFonts.jakarta(
                                    fontSize: 12.5,
                                    color: EventDetailColors.primaryBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.open_in_new_rounded,
                          color: EventDetailColors.primaryBlue),
                    ],
                  ),
                ),
              ),
            ),
          ],
          if (!isMeetingPrimary && link.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Meeting link',
              style: EventManagementFonts.jakarta(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.5,
                  ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => _open(link),
              icon: const Icon(Icons.link_rounded, size: 18),
              label: Text(
                link.length > 40 ? '${link.substring(0, 37)}…' : link,
                style: EventManagementFonts.jakarta(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: EventDetailColors.primaryBlue,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _header(String title, {IconData icon = Icons.pin_drop_outlined}) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.textSecondary, size: 22),
        const SizedBox(width: 10),
        Text(
          title,
          style: EventManagementFonts.detailSectionTitle(),
        ),
      ],
    );
  }

  Future<void> _open(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
