import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/event_management/features/events/domain/entities/event.dart';
import 'package:my_app/event_management/features/events/presentation/screens/event_detail_screen.dart';
import 'package:my_app/event_management/shared/themes/app_theme.dart';

class DashboardTodayGrid extends StatelessWidget {
  final List<Event> events;
  final EdgeInsetsGeometry sectionPadding;

  const DashboardTodayGrid({
    super.key,
    required this.events,
    this.sectionPadding = const EdgeInsets.fromLTRB(24, 20, 24, 0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // Pure white base
      padding: sectionPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "Today's Events",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900, // Bold SaaS typography
                  color: Color(0xFF0F172A), // Slate 900
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              // Minimalist Filter Action
              _buildIconButton(Icons.tune_rounded),
            ],
          ),
          const SizedBox(height: 16),
          if (events.isEmpty)
            _empty(context, 'You’re all caught up for today.')
          else
            LayoutBuilder(
              builder: (context, c) {
                final cols = c.maxWidth >= 800 ? 2 : 1;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    mainAxisExtent: 90, // Tighter card height
                  ),
                  itemCount: events.take(4).length,
                  itemBuilder: (_, i) => _TodayCard(event: events[i]),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Icon(icon, size: 16, color: const Color(0xFF64748B)),
    );
  }

  Widget _empty(BuildContext context, String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Text(
        msg,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF94A3B8),
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  final Event event;
  const _TodayCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse('0xFF${event.displayColor.replaceAll('#', '')}'));
    final start = event.startTime.toLocal();
    final time = event.isAllDay ? 'All day' : DateFormat.jm().format(start);
    final loc = (event.location ?? '').trim();

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => EventDetailScreen(eventId: event.id)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Circular Minimalist Icon
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.edit_rounded, color: color, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      // SaaS Type Tag
                      _buildTag(event.type.label.toUpperCase(), color),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (loc.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          child: Text("•", style: TextStyle(color: Color(0xFFCBD5E1))),
                        ),
                        Expanded(
                          child: Text(
                            loc,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
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
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w900,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}