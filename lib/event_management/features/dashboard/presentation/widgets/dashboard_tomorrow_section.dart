import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/event_management/features/events/domain/entities/event.dart';
import 'package:my_app/event_management/features/events/presentation/screens/event_detail_screen.dart';
import 'package:my_app/event_management/shared/themes/app_theme.dart';

class DashboardTomorrowSection extends StatelessWidget {
  final List<Event> upcoming;

  const DashboardTomorrowSection({super.key, required this.upcoming});

  @override
  Widget build(BuildContext context) {
    final tomorrow = DateTime.now().toLocal().add(const Duration(days: 1));
    final list = upcoming
        .where((e) => _isSameDay(e.startTime.toLocal(), tomorrow))
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Tomorrow, ${DateFormat('MMM d').format(tomorrow)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/calendar');
                },
                child: const Text('View Calendar'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border:
                  Border.all(color: AppTheme.borderLight.withValues(alpha: 0.9)),
            ),
            child: list.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(18),
                    child: Text(
                      'No events scheduled for tomorrow.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: list.take(3).length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: AppTheme.borderLight.withValues(alpha: 0.8),
                    ),
                    itemBuilder: (context, i) => _TomorrowRow(event: list[i]),
                  ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _TomorrowRow extends StatelessWidget {
  final Event event;
  const _TomorrowRow({required this.event});

  @override
  Widget build(BuildContext context) {
    final start = event.startTime.toLocal();
    final time = event.isAllDay ? 'All day' : DateFormat.Hm().format(start);
    final color =
        Color(int.parse('0xFF${event.displayColor.replaceAll('#', '')}'));

    return InkWell(
      onTap: () {
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => EventDetailScreen(eventId: event.id),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        child: Row(
          children: [
            SizedBox(
              width: 44,
              child: Text(
                time,
                style: const TextStyle(
                  color: AppTheme.textHint,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _subtitle(),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                event.type.label.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.more_vert_rounded,
                size: 18, color: AppTheme.textHint),
          ],
        ),
      ),
    );
  }

  String _subtitle() {
    final loc = (event.location ?? '').trim();
    if (loc.isNotEmpty) return loc;
    if ((event.meetingLink ?? '').trim().isNotEmpty) return 'Online meeting';
    return 'Scheduled';
  }
}

