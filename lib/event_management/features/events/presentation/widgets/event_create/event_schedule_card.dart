import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/event_management/shared/themes/app_theme.dart';

import 'event_composer_white_card.dart';

/// Schedule card with all-day switch and start/end date-time blocks.
class EventScheduleCard extends StatelessWidget {
  final bool isAllDay;
  final ValueChanged<bool> onAllDayChanged;
  final DateTime start;
  final DateTime end;
  final VoidCallback onPickStartDate;
  final VoidCallback onPickStartTime;
  final VoidCallback onPickEndDate;
  final VoidCallback onPickEndTime;

  const EventScheduleCard({
    super.key,
    required this.isAllDay,
    required this.onAllDayChanged,
    required this.start,
    required this.end,
    required this.onPickStartDate,
    required this.onPickStartTime,
    required this.onPickEndDate,
    required this.onPickEndTime,
  });

  @override
  Widget build(BuildContext context) {
    return EventComposerWhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  color: AppTheme.primaryBlue,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Schedule',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const Spacer(),
              Text(
                'All Day',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              Switch.adaptive(
                value: isAllDay,
                onChanged: onAllDayChanged,
                activeTrackColor:
                    AppTheme.primaryBlue.withValues(alpha: 0.35),
                activeThumbColor: AppTheme.primaryBlue,
              ),
            ],
          ),
          const SizedBox(height: 16),
          EventDateTimeBlock(
            label: 'Starts',
            date: start,
            showTime: !isAllDay,
            onDateTap: onPickStartDate,
            onTimeTap: onPickStartTime,
          ),
          const SizedBox(height: 12),
          EventDateTimeBlock(
            label: 'Ends',
            date: end,
            showTime: !isAllDay,
            onDateTap: onPickEndDate,
            onTimeTap: onPickEndTime,
          ),
        ],
      ),
    );
  }
}

/// One row: label, tappable date, optional tappable time (primary color).
class EventDateTimeBlock extends StatelessWidget {
  final String label;
  final DateTime date;
  final bool showTime;
  final VoidCallback onDateTap;
  final VoidCallback onTimeTap;

  const EventDateTimeBlock({
    super.key,
    required this.label,
    required this.date,
    required this.showTime,
    required this.onDateTap,
    required this.onTimeTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEEE, MMM d').format(date);
    final timeStr = DateFormat.jm().format(date);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onDateTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      dateStr,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
              ),
              if (showTime)
                InkWell(
                  onTap: onTimeTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      timeStr,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryBlue,
                          ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
