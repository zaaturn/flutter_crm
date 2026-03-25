import 'package:flutter/foundation.dart';

class Participant {
  final int id;
  final String name;
  final String email;

  const Participant({
    required this.id,
    required this.name,
    required this.email,
  });
}

class EventEntity {
  final int? id;
  final String title;
  final String description;
  final DateTime start;
  final DateTime end;
  final String meetingLink;
  final String eventType;
  final List<Participant> participants;
  final int reminderBefore;
  final String color;

  const EventEntity({
    this.id,
    required this.title,
    required this.description,
    required this.start,
    required this.end,
    this.meetingLink = '',
    required this.eventType,
    this.participants = const [],
    required this.reminderBefore,
    this.color = '#6366F1',
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EventEntity) return false;
    return id == other.id &&
        title == other.title &&
        description == other.description &&
        start == other.start &&
        end == other.end &&
        meetingLink == other.meetingLink &&
        eventType == other.eventType &&
        color == other.color &&
        _listEq(participants, other.participants) &&
        reminderBefore == other.reminderBefore;
  }

  @override
  int get hashCode => Object.hash(
    id, title, description, start, end,
    meetingLink, eventType, participants, reminderBefore, color,
  );

  EventEntity copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? start,
    DateTime? end,
    String? meetingLink,
    String? eventType,
    List<Participant>? participants,
    int? reminderBefore,
    String? color,
  }) => EventEntity(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    start: start ?? this.start,
    end: end ?? this.end,
    meetingLink: meetingLink ?? this.meetingLink,
    eventType: eventType ?? this.eventType,
    participants: participants ?? this.participants,
    reminderBefore: reminderBefore ?? this.reminderBefore,
    color: color ?? this.color,
  );
}

bool _listEq(List<Participant> a, List<Participant> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i].id != b[i].id) return false;
  }
  return true;
}