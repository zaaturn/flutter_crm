import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/event_management/features/events/domain/entities/event.dart';
import 'package:my_app/event_management/features/events/presentation/screens/mobile/screen/MOBILE/event_detail_screen_mobile.dart';
import 'package:my_app/event_management/features/calendar/presentation/screen/mobile_screen/event_calendar_mobile_screen.dart';

class ZaaturnUI {
  static const Color background = Color(0xFFFAF3E0);
  static const Color cardBeige = Color(0xFFEADBC8);
  static const Color accentOrange = Color(0xFFF3924C);
  static const Color textDark = Color(0xFF3E2723);
  static const Color textMuted = Color(0xFF8D6E63);
}

class DashboardTomorrowSectionMobile extends StatelessWidget {
  final List<Event> upcoming;

  const DashboardTomorrowSectionMobile({super.key, required this.upcoming});

  @override
  Widget build(BuildContext context) {
    final tomorrow = DateTime.now().toLocal().add(const Duration(days: 1));
    final list = upcoming
        .where((e) => _isSameDay(e.startTime.toLocal(), tomorrow))
        .toList()
      ..sort((a, b) => a.startTime.toLocal().compareTo(b.startTime.toLocal()));

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tomorrow, ${DateFormat('MMM d').format(tomorrow)}',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: ZaaturnUI.textDark,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const EventCalendarMobileScreen()),
                ),
                child: Text(
                  'Calendar',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: ZaaturnUI.accentOrange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          list.isEmpty
              ? _buildEmptyState()
              : Container(
            decoration: BoxDecoration(
              color: ZaaturnUI.cardBeige,
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                indent: 12,
                endIndent: 12,
                color: ZaaturnUI.textDark.withOpacity(0.05),
              ),
              itemBuilder: (context, i) => _TomorrowMobileRow(event: list[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: ZaaturnUI.cardBeige.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          "No events tomorrow",
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: ZaaturnUI.textMuted,
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _TomorrowMobileRow extends StatelessWidget {
  final Event event;
  const _TomorrowMobileRow({required this.event});

  Color get _typeColor => Color(int.parse('0xFF${event.displayColor.replaceAll('#', '')}'));

  IconData get _typeIcon {
    switch (event.type) {
      case EventType.meeting: return Icons.videocam_rounded;
      case EventType.task: return Icons.check_circle_rounded;
      case EventType.reminder: return Icons.notifications_rounded;
      case EventType.personal: return Icons.person_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final start = event.startTime.toLocal();
    final time = event.isAllDay ? 'All day' : DateFormat.jm().format(start);

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => EventDetailMobileScreen(eventId: event.id)),
      ),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    time,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      color: ZaaturnUI.accentOrange,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    event.title,
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: ZaaturnUI.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _typeColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_typeIcon, size: 10, color: _typeColor),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            event.type.label,
                            style: GoogleFonts.manrope(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: ZaaturnUI.textDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _subtitle(),
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      color: ZaaturnUI.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, color: ZaaturnUI.textMuted, size: 16),
          ],
        ),
      ),
    );
  }

  String _subtitle() {
    final loc = (event.location ?? '').trim();
    if (loc.isNotEmpty) return loc;
    if ((event.meetingLink ?? '').trim().isNotEmpty) return 'Online';
    return 'Scheduled';
  }
}