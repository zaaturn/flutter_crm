import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/event_management/features/events/domain/entities/event.dart';
import 'package:my_app/event_management/features/events/presentation/screens/mobile/screen/MOBILE/event_detail_screen_mobile.dart';

class ZaaturnUI {
  static const Color background = Color(0xFFFAF3E0); // Light Cream
  static const Color cardBeige = Color(0xFFEADBC8);   // Terracotta-Beige
  static const Color accentOrange = Color(0xFFF3924C);
  static const Color textDark = Color(0xFF3E2723);    // Deep Coffee
  static const Color textMuted = Color(0xFF8D6E63);
}

class DashboardTodayGridMobile extends StatelessWidget {
  final List<Event> events;

  const DashboardTodayGridMobile({
    super.key,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ZaaturnUI.background,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today's Events",
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: ZaaturnUI.textDark,
                ),
              ),
              if (events.length > 4)
                Text(
                  "View all",
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: ZaaturnUI.accentOrange,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Logic: Check if list is empty, if so show the "Relax" box
          if (events.isEmpty)
            _buildEmptyState()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events.take(4).length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _TodayMobileCard(event: events[i]),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ZaaturnUI.cardBeige.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ZaaturnUI.textMuted.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.coffee_rounded, // Coffee icon for a relaxed start
            color: ZaaturnUI.textMuted.withOpacity(0.5),
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            "Just relax! You're all caught up for today.",
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: ZaaturnUI.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayMobileCard extends StatelessWidget {
  final Event event;
  const _TodayMobileCard({required this.event});

  Color get _typeColor =>
      Color(int.parse('0xFF${event.displayColor.replaceAll('#', '')}'));

  IconData get _typeIcon {
    switch (event.type) {
      case EventType.meeting:
        return Icons.videocam_rounded;
      case EventType.task:
        return Icons.task_alt_rounded;
      case EventType.reminder:
        return Icons.notifications_active_rounded;
      case EventType.personal:
        return Icons.person_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final start = event.startTime.toLocal();
    final time = event.isAllDay ? 'All day' : DateFormat.jm().format(start);
    final loc = (event.location ?? '').trim();

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => EventDetailMobileScreen(eventId: event.id),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ZaaturnUI.cardBeige,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: ZaaturnUI.textMuted.withOpacity(0.10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: _typeColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: ZaaturnUI.textDark,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _TypeChip(
                        icon: _typeIcon,
                        label: event.type.label,
                        color: _typeColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 14, color: ZaaturnUI.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: ZaaturnUI.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (loc.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Icon(Icons.location_on_rounded, size: 14, color: ZaaturnUI.textMuted),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            loc,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: ZaaturnUI.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: ZaaturnUI.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _TypeChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: ZaaturnUI.textDark,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}