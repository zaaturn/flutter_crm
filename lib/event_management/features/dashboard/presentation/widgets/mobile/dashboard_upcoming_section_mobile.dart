import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/event_management/features/events/domain/entities/event.dart';
import 'package:my_app/event_management/features/events/presentation/widgets/event_card_mobile.dart';

class ZaaturnUI {
  static const Color background = Color(0xFFFAF3E0); // Light Cream
  static const Color cardBeige = Color(0xFFEADBC8);   // Terracotta-Beige
  static const Color accentOrange = Color(0xFFF3924C);
  static const Color textDark = Color(0xFF3E2723);    // Deep Coffee
  static const Color textMuted = Color(0xFF8D6E63);
}

class DashboardUpcomingSectionMobile extends StatelessWidget {
  final List<Event> upcoming;
  final int maxItems;

  const DashboardUpcomingSectionMobile({
    super.key,
    required this.upcoming,
    this.maxItems = 6,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().toLocal();
    final todayStart = DateTime(now.year, now.month, now.day);

    // Filter events that start after today
    final list = upcoming.where((e) {
      final local = e.startTime.toLocal();
      final d = DateTime(local.year, local.month, local.day);
      return d.isAfter(todayStart);
    }).toList()
      // Newest first (Apr 23 before Apr 22)
      ..sort((a, b) => b.startTime.toLocal().compareTo(a.startTime.toLocal()));

    final shown = list.take(maxItems).toList();

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
                'Upcoming Events',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: ZaaturnUI.textDark,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pushNamed('/calendar'),
                child: Text(
                  'Calendar',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: ZaaturnUI.accentOrange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (shown.isEmpty)
            _buildEmptyState()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: shown.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => EventCardMobile(
                event: shown[i],
                compact: true,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ZaaturnUI.cardBeige.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'No upcoming events.',
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          color: ZaaturnUI.textMuted,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}