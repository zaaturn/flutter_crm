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
            const SizedBox(height: 12),
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
          const SizedBox(height: 12),
          if (!isMeetingPrimary) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: EventDetailColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.location_on_outlined,
                    size: 22,
                    color: EventDetailColors.primaryBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.split(',').first.trim().isEmpty
                            ? 'Location'
                            : loc.split(',').first.trim(),
                        style: EventManagementFonts.jakarta(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        loc,
                        style: EventManagementFonts.bodyReading().copyWith(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            InkWell(
              onTap: () => _open(link),
              borderRadius: BorderRadius.circular(12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: EventDetailColors.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.video_call_rounded,
                      color: EventDetailColors.primaryBlue,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Join meeting',
                          style: EventManagementFonts.jakarta(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
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
                  const Icon(
                    Icons.open_in_new_rounded,
                    size: 18,
                    color: EventDetailColors.primaryBlue,
                  ),
                ],
              ),
            ),
          ],
          if (!isMeetingPrimary && link.isNotEmpty) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _open(link),
              borderRadius: BorderRadius.circular(12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: EventDetailColors.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.link_rounded,
                      size: 20,
                      color: EventDetailColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      link.length > 50 ? '${link.substring(0, 47)}…' : link,
                      style: EventManagementFonts.jakarta(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: EventDetailColors.primaryBlue,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(
                    Icons.open_in_new_rounded,
                    size: 18,
                    color: EventDetailColors.primaryBlue,
                  ),
                ],
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
    final normalized = _normalizeWebUrl(url);
    final uri = Uri.tryParse(normalized);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _normalizeWebUrl(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return v;
    final lower = v.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) return v;
    return 'https://$v';
  }
}
