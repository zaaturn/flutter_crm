import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/calendar_holiday.dart';
import '../../shared/holiday_ui_theme.dart';

void showHolidayPopover(
  BuildContext context, {
  required CalendarHoliday holiday,
  Offset? anchor,
}) {
  final dt = holiday.dateTime ?? DateTime.now();
  final dateLabel = DateFormat('EEEE, MMMM d, yyyy').format(dt);

  showDialog<void>(
    context: context,
    barrierColor: Colors.black26,
    builder: (ctx) => Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 320,
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: HolidayUiTheme.bg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    HolidayUiTheme.flag,
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      holiday.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: HolidayUiTheme.text,
                      ),
                    ),
                  ),
                ],
              ),
              if (holiday.localName.trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  holiday.localName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: HolidayUiTheme.text.withValues(alpha: 0.85),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                dateLabel,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7F78),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'National Public Holiday',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: HolidayUiTheme.orange,
                ),
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
