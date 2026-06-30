import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../shared/calendar_palette.dart';

class CalendarGridEvent extends Equatable {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final bool isAllDay;
  final String eventType;
  final String? location;
  final String recurrence;
  final String? taskStatus;
  final String? priority;
  final bool isCancelled;
  final String? timezoneName;
  final int participantCount;
  final bool hasReminder;
  final bool isTaskDeadline;
  final String? dueDate;
  final String? assignedTo;
  final String? userColorHex;

  const CalendarGridEvent({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.isAllDay = false,
    this.eventType = 'meeting',
    this.location,
    this.recurrence = 'none',
    this.taskStatus,
    this.priority,
    this.isCancelled = false,
    this.timezoneName,
    this.participantCount = 0,
    this.hasReminder = false,
    this.isTaskDeadline = false,
    this.dueDate,
    this.assignedTo,
    this.userColorHex,
  });

  bool get isTaskApiId => id.startsWith('task_');

  Color get blockColor {
    if (isCancelled) return CalendarPalette.cancelled;
    if (isTaskDeadline) return CalendarPalette.taskDeadline.withValues(alpha: 0.12);
    return CalendarPalette.eventTypeColor(eventType, userColorHex: userColorHex);
  }

  Color get priorityBorderColor => CalendarPalette.priorityBorder(priority);

  factory CalendarGridEvent.fromJson(Map<String, dynamic> json) {
    DateTime parseDt(dynamic v) {
      if (v == null) return DateTime.now();
      return DateTime.tryParse(v.toString()) ?? DateTime.now();
    }

    return CalendarGridEvent(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled',
      startTime: parseDt(json['start_time']),
      endTime: parseDt(json['end_time'] ?? json['start_time']),
      isAllDay: json['is_all_day'] == true,
      eventType: json['event_type']?.toString() ?? 'meeting',
      location: json['location']?.toString(),
      recurrence: json['recurrence']?.toString() ?? 'none',
      taskStatus: json['task_status']?.toString(),
      priority: json['priority']?.toString(),
      isCancelled: json['is_cancelled'] == true,
      timezoneName: json['timezone_name']?.toString(),
      participantCount: json['participant_count'] is int
          ? json['participant_count'] as int
          : int.tryParse('${json['participant_count']}') ?? 0,
      hasReminder: json['has_reminder'] == true,
      isTaskDeadline: json['is_task_deadline'] == true,
      dueDate: json['due_date']?.toString(),
      assignedTo: json['assigned_to']?.toString(),
      userColorHex: json['color']?.toString(),
    );
  }

  @override
  List<Object?> get props => [id, startTime, endTime, title, isCancelled];
}

class CalendarReminderItem extends Equatable {
  final int reminderId;
  final String eventId;
  final String eventTitle;
  final DateTime fireAt;
  final bool isOverdue;

  const CalendarReminderItem({
    required this.reminderId,
    required this.eventId,
    required this.eventTitle,
    required this.fireAt,
    this.isOverdue = false,
  });

  factory CalendarReminderItem.fromJson(Map<String, dynamic> json) {
    return CalendarReminderItem(
      reminderId: json['reminder_id'] is int
          ? json['reminder_id'] as int
          : int.tryParse('${json['reminder_id']}') ?? 0,
      eventId: json['event_id']?.toString() ?? '',
      eventTitle: json['event_title']?.toString() ?? '',
      fireAt: DateTime.tryParse(json['fire_at']?.toString() ?? '') ??
          DateTime.now(),
      isOverdue: json['is_overdue'] == true,
    );
  }

  @override
  List<Object?> get props => [reminderId, eventId, fireAt];
}
