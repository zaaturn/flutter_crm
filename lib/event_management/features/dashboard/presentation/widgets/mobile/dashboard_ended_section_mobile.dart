import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:my_app/event_management/features/events/domain/entities/event.dart';
import 'package:my_app/event_management/features/events/presentation/screens/mobile/event_detail_screen_mobile.dart';

class ZaaturnUI {
  static const Color background = Color(0xFFFAF3E0);
  static const Color cardBeige = Color(0xFFEADBC8);
  static const Color accentOrange = Color(0xFFF3924C);
  static const Color textDark = Color(0xFF3E2723);
  static const Color textMuted = Color(0xFF8D6E63);
}

class DashboardEndedSectionMobile extends StatelessWidget {
  final List<Event> endedEvents;

  const DashboardEndedSectionMobile({super.key, required this.endedEvents});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    // Logic: Filter to only show events that ended TODAY
    final todayEnded = endedEvents.where((e) {
      final localStart = e.startTime.toLocal();
      return localStart.year == now.year &&
          localStart.month == now.month &&
          localStart.day == now.day;
    }).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Ended Today',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: ZaaturnUI.textDark,
                ),
              ),
              const SizedBox(width: 10),
              if (todayEnded.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: ZaaturnUI.accentOrange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${todayEnded.length}',
                    style: GoogleFonts.manrope(
                      color: ZaaturnUI.accentOrange,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Logic: If no events ended today, show the "Relax" message
          if (todayEnded.isEmpty)
            _buildRelaxState()
          else
            ...todayEnded.take(3).map((e) => _EndedMobileCard(event: e)),
        ],
      ),
    );
  }

  Widget _buildRelaxState() {
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
          Icon(Icons.sentiment_satisfied_alt_rounded,
              color: ZaaturnUI.textMuted.withOpacity(0.5), size: 32),
          const SizedBox(height: 8),
          Text(
            "Just relax! No events completed today.",
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

class _EndedMobileCard extends StatelessWidget {
  final Event event;
  const _EndedMobileCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final start = event.startTime.toLocal();

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => EventDetailMobileScreen(eventId: event.id),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ZaaturnUI.cardBeige.withOpacity(0.7),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: ZaaturnUI.textMuted.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('MMM').format(start).toUpperCase(),
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: ZaaturnUI.textMuted,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${start.day}',
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: ZaaturnUI.textDark,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: ZaaturnUI.textDark.withOpacity(0.6),
                      decoration: TextDecoration.lineThrough,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.history_rounded, size: 14, color: ZaaturnUI.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        'Finished',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: ZaaturnUI.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: ZaaturnUI.accentOrange,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Review',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}