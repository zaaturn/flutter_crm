import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/event.dart';
import 'package:my_app/event_management/shared/themes/app_theme.dart';
import 'package:my_app/event_management/shared/themes/event_management_fonts.dart';

import 'event_detail_constants.dart';
import 'event_detail_surface_card.dart';

class EventDetailScheduleCard extends StatelessWidget {
  final Event event;

  const EventDetailScheduleCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final startLocal = event.startTime.toLocal();
    final endLocal = event.endTime.toLocal();
    final uniqueReminders = () {
      final seen = <int>{};
      final out = <EventReminder>[];
      for (final r in event.reminders) {
        if (seen.add(r.minutesBefore)) {
          out.add(r);
        }
      }
      return out;
    }();

    return EventDetailSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: EventDetailColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  color: EventDetailColors.primaryBlue,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Schedule Details',
                style: EventManagementFonts.detailSectionTitle(),
              ),
            ],
          ),

          const SizedBox(height: 22),

          LayoutBuilder(
            builder: (context, c) {
              final stack = c.maxWidth < 420;

              final startCol = _timeColumn(
                context,
                'STARTS',
                DateFormat('MMMM d, yyyy').format(startLocal),
                event.isAllDay
                    ? 'All day'
                    : DateFormat.jm().format(startLocal),
              );

              final endCol = _timeColumn(
                context,
                'ENDS',
                DateFormat('MMMM d, yyyy').format(endLocal),
                event.isAllDay
                    ? 'All day'
                    : DateFormat.jm().format(endLocal),
              );

              if (stack) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    startCol,
                    const SizedBox(height: 20),
                    endCol,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: startCol),
                  const SizedBox(width: 24),
                  Expanded(child: endCol),
                ],
              );
            },
          ),

          const SizedBox(height: 16),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Times shown in ${DateTime.now().timeZoneName} (local).',
                    ),
                  ),
                );
              },
              child: Text(
                'Adjust Timezone',
                style: EventManagementFonts.jakarta(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: EventDetailColors.primaryBlue,
                ),
              ),
            ),
          ),

          if (event.recurrence != RecurrenceRule.none) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.repeat_rounded,
                    size: 18, color: AppTheme.textSecondary),
                const SizedBox(width: 8),
                Text(
                  'Repeats ${event.recurrence.name}',
                  style: EventManagementFonts.jakarta(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],

          if (event.reminders.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              'Reminders',
              style: EventManagementFonts.jakarta(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppTheme.textSecondary,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: uniqueReminders
                  .map(
                    (r) => Chip(
                  label: Text(r.label),
                  avatar: const Icon(Icons.alarm, size: 16),
                  visualDensity: VisualDensity.compact,
                  side: BorderSide(color: AppTheme.borderLight),
                ),
              )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _timeColumn(
    BuildContext context,
    String label,
      String dateLine,
    String timeLine,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: EventManagementFonts.detailScheduleLabel(),
        ),
        const SizedBox(height: 8),
        Text(
          dateLine,
          style: EventManagementFonts.detailScheduleDate(),
        ),
        const SizedBox(height: 4),
        Text(
          timeLine,
          style: EventManagementFonts.detailScheduleTime().copyWith(
            color: EventDetailColors.primaryBlue,
          ),
        ),
      ],
    );
  }
}
