import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/event_management/features/events/domain/entities/event.dart';
import 'package:my_app/event_management/features/events/presentation/screens/event_detail_screen.dart';
import 'package:my_app/event_management/shared/themes/app_theme.dart';

class DashboardUpcomingSection extends StatelessWidget {
  final List<Event> upcoming;
  final EdgeInsetsGeometry sectionPadding;
  final int maxItems;

  const DashboardUpcomingSection({
    super.key,
    required this.upcoming,
    this.sectionPadding = const EdgeInsets.fromLTRB(24, 28, 24, 0),
    this.maxItems = 6, // Slightly reduced for cleaner look
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().toLocal();
    final todayStart = DateTime(now.year, now.month, now.day);

    final list = upcoming.where((e) {
      final local = e.startTime.toLocal();
      final d = DateTime(local.year, local.month, local.day);
      return d.isAfter(todayStart);
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final shown = list.take(maxItems).toList();

    return Container(
      color: Colors.white, // Pure white background
      padding: sectionPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Upcoming Events',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.of(context).pushNamed('/calendar'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF0D3199),
                  textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                child: const Text('View Calendar'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (shown.isEmpty)
            _buildEmptyState()
          else
          // Changed from a single box to individual rows or a clean list
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: shown.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) => _UpcomingRow(event: shown[i]),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: const Text(
        'No upcoming events scheduled.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _UpcomingRow extends StatelessWidget {
  final Event event;
  const _UpcomingRow({required this.event});

  @override
  Widget build(BuildContext context) {
    final start = event.startTime.toLocal();
    final dateLabel = DateFormat('EEE, MMM d').format(start);
    final time = event.isAllDay ? 'All day' : DateFormat.jm().format(start);
    final color = Color(int.parse('0xFF${event.displayColor.replaceAll('#', '')}'));

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => EventDetailScreen(eventId: event.id)),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Date & Time Block
            SizedBox(
              width: 85,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateLabel.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF0D3199), // Brand color for dates
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    time,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Vertical Separator
            Container(
              height: 24,
              width: 1,
              color: const Color(0xFFE2E8F0),
              margin: const EdgeInsets.symmetric(horizontal: 12),
            ),
            // Status Dot
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            // Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _subtitle(),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // SaaS-style Type Tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                event.type.label.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
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