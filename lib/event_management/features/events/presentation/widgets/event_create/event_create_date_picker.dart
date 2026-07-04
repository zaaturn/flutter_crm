import 'package:flutter/material.dart';
import 'package:my_app/core/ui/adaptive_layout.dart';
import 'package:my_app/event_management/features/events/presentation/mobile/mobile_event_theme.dart';

/// Terracotta-themed date/time pickers on mobile.
abstract final class EventCreateDateTimePicker {
  static Future<void> pick({
    required BuildContext context,
    required bool isAllDay,
    required bool isStart,
    required bool timeOnly,
    required DateTime startTime,
    required DateTime endTime,
    required void Function(DateTime start, DateTime end) onApply,
  }) async {
    if (isAllDay && timeOnly) return;

    final initial = isStart ? startTime : endTime;
    final mobile = AdaptiveLayout.useMobileUi(context);

    if (timeOnly) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initial),
        builder: mobile ? _themedPicker : null,
      );
      if (time == null || !context.mounted) return;

      DateTime nextStart = startTime;
      DateTime nextEnd = endTime;

      if (isStart) {
        nextStart = DateTime(
          startTime.year,
          startTime.month,
          startTime.day,
          time.hour,
          time.minute,
        );
        if (!nextEnd.isAfter(nextStart)) {
          nextEnd = nextStart.add(const Duration(hours: 1));
        }
      } else {
        final candidate = DateTime(
          endTime.year,
          endTime.month,
          endTime.day,
          time.hour,
          time.minute,
        );
        if (candidate.isAfter(startTime)) {
          nextEnd = candidate;
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('End must be after start')),
            );
          }
          return;
        }
      }
      onApply(nextStart, nextEnd);
      return;
    }

    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(initial.year, initial.month, initial.day),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: mobile ? _themedPicker : null,
    );
    if (date == null || !context.mounted) return;

    DateTime nextStart = startTime;
    DateTime nextEnd = endTime;

    if (isAllDay) {
      if (isStart) {
        nextStart = DateTime(date.year, date.month, date.day);
        var endDay = DateTime(endTime.year, endTime.month, endTime.day);
        if (endDay.isBefore(DateTime(date.year, date.month, date.day))) {
          endDay = DateTime(date.year, date.month, date.day);
        }
        nextEnd = DateTime(endDay.year, endDay.month, endDay.day, 23, 59, 59);
      } else {
        final startDay =
            DateTime(startTime.year, startTime.month, startTime.day);
        final picked = DateTime(date.year, date.month, date.day);
        if (picked.isBefore(startDay)) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('End date cannot be before start')),
            );
          }
          return;
        }
        nextEnd = DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
      }
      onApply(nextStart, nextEnd);
      return;
    }

    if (isStart) {
      nextStart = DateTime(
        date.year,
        date.month,
        date.day,
        startTime.hour,
        startTime.minute,
      );
      if (!nextEnd.isAfter(nextStart)) {
        nextEnd = nextStart.add(const Duration(hours: 1));
      }
    } else {
      final candidate = DateTime(
        date.year,
        date.month,
        date.day,
        endTime.hour,
        endTime.minute,
      );
      if (candidate.isAfter(startTime)) {
        nextEnd = candidate;
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('End must be after start')),
          );
        }
        return;
      }
    }
    onApply(nextStart, nextEnd);
  }

  static Widget _themedPicker(BuildContext context, Widget? child) {
    return Theme(
      data: MobileEventTheme.themeData(context),
      child: child ?? const SizedBox.shrink(),
    );
  }
}
