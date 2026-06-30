import 'package:equatable/equatable.dart';
import 'package:my_app/event_management/core/entities/user.dart';

enum EventType { meeting, task, reminder, personal }

enum RecurrenceRule { none, daily, weekly, monthly }

extension EventTypeExtension on EventType {
  String get label {
    switch (this) {
      case EventType.meeting:  return 'Meeting';
      case EventType.task:     return 'Task';
      case EventType.reminder: return 'Reminder';
      case EventType.personal: return 'Personal';
    }
  }

  String get color {
    switch (this) {
      case EventType.meeting:  return '#E24B4A';
      case EventType.task:     return '#378ADD';
      case EventType.reminder: return '#EF9F27';
      case EventType.personal: return '#1D9E75';
    }
  }

  static EventType fromString(String value) {
    return EventType.values.firstWhere(
          (e) => e.name == value,
      orElse: () => EventType.meeting,
    );
  }
}

class Participant extends Equatable {
  final String id;
  final String username;
  final String? avatar;
  final String status; // pending | accepted | declined

  const Participant({
    required this.id,
    required this.username,
    this.avatar,
    this.status = 'pending',
  });

  @override
  List<Object?> get props => [id];
}

class EventReminder extends Equatable {
  final int id;
  final int minutesBefore;

  const EventReminder({required this.id, required this.minutesBefore});

  String get label {
    if (minutesBefore == 10)  return '10 min before';
    if (minutesBefore == 30)  return '30 min before';
    if (minutesBefore == 60)  return '1 hour before';
    if (minutesBefore == 1440) return '1 day before';
    return '$minutesBefore min before';
  }

  @override
  List<Object?> get props => [id, minutesBefore];
}

class Event extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final bool isAllDay;
  final EventType type;
  final String colorOverride;
  final String? meetingLink;
  final String? location;
  final RecurrenceRule recurrence;
  final DateTime? recurrenceEnd;
  final List<Participant> participants;
  final List<EventReminder> reminders;
  final User createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Event({
    required this.id,
    required this.title,
    this.description = '',
    required this.startTime,
    required this.endTime,
    this.isAllDay = false,
    required this.type,
    this.colorOverride = '',
    this.meetingLink,
    this.location,
    this.recurrence = RecurrenceRule.none,
    this.recurrenceEnd,
    this.participants = const [],
    this.reminders = const [],
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  String get displayColor =>
      colorOverride.isNotEmpty ? colorOverride : type.color;

  bool conflictsWith(Event other) =>
      id != other.id &&
          startTime.isBefore(other.endTime) &&
          endTime.isAfter(other.startTime);

  bool get isToday {
    final now = DateTime.now();
    return startTime.year == now.year &&
        startTime.month == now.month &&
        startTime.day == now.day;
  }

  bool get isMissed =>
      endTime.isBefore(DateTime.now());

  bool get isUpcoming =>
      startTime.isAfter(DateTime.now());

  Duration get duration => endTime.difference(startTime);

  /// Participant row for this user id (API usually stores user id on participant).
  Participant? participantForUser(String userId) {
    for (final p in participants) {
      if (p.id == userId) return p;
    }
    return null;
  }

  /// True when this user is a participant and still needs to accept/decline.
  bool invitePendingForUser(String userId) {
    final p = participantForUser(userId);
    if (p == null) return false;
    return p.status.toLowerCase() == 'pending';
  }

  /// True when [userId] matches the event host / creator.
  bool isOwnedBy(String? userId) =>
      userId != null &&
      userId.isNotEmpty &&
      userId == createdBy.id.toString();

  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    bool? isAllDay,
    EventType? type,
    String? colorOverride,
    String? meetingLink,
    String? location,
    RecurrenceRule? recurrence,
    DateTime? recurrenceEnd,
    List<Participant>? participants,
    List<EventReminder>? reminders,
    User? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAllDay: isAllDay ?? this.isAllDay,
      type: type ?? this.type,
      colorOverride: colorOverride ?? this.colorOverride,
      meetingLink: meetingLink ?? this.meetingLink,
      location: location ?? this.location,
      recurrence: recurrence ?? this.recurrence,
      recurrenceEnd: recurrenceEnd ?? this.recurrenceEnd,
      participants: participants ?? this.participants,
      reminders: reminders ?? this.reminders,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, title, startTime, endTime, type];
}