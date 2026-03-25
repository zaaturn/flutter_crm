import 'package:my_app/event_management/features/domain/entities/event_entity.dart';

class EventModel extends EventEntity {
  const EventModel({
    super.id,
    required super.title,
    required super.description,
    required super.start,
    required super.end,
    super.meetingLink = '',
    required super.eventType,
    super.participants = const [],
    required super.reminderBefore,
    super.color,
  });

  // ─────────────────────────────────────────────
  // JSON → Model
  // ─────────────────────────────────────────────
  factory EventModel.fromJson(Map<String, dynamic> json) {


    return EventModel(
      id: json['id'] as int?,
      title: json['title'] as String,
      description: (json['description'] as String?) ?? '',
      start: DateTime.parse(json['start'] as String).toLocal(),
      end: DateTime.parse(json['end'] as String).toLocal(),
      meetingLink: (json['meeting_link'] as String?) ?? '',
      eventType: json['event_type'] as String,

      participants: (json['participants'] as List<dynamic>? ?? [])
          .map((e) {
        if (e is Map<String, dynamic>) {
          final userData = e['user'] ?? e['employee'] ?? e;


          final String firstName = userData['first_name'] ?? '';
          final String lastName = userData['last_name'] ?? '';
          final String username = userData['username'] ?? '';

          String fullName = '$firstName $lastName'.trim();


          if (fullName.isEmpty) {
            fullName = username.isNotEmpty
                ? username
                : (userData['email'] ?? 'User ${userData['id'] ?? e['id']}');
          }

          return Participant(
            id: (userData['id'] ?? e['id']) as int,
            name: fullName,
            email: (userData['email'] as String?) ?? '',
          );
        }


        return Participant(
            id: e as int,
            name: 'User $e',
            email: ''
        );
      })
          .toList(),

      reminderBefore: json['reminder_before'] as int,
      color: (json['color'] as String?) ?? '#6366F1',
    );
  }

  // ─────────────────────────────────────────────
  // Model → JSON
  // ─────────────────────────────────────────────
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'start': start.toUtc().toIso8601String(),
      'end': end.toUtc().toIso8601String(),
      'meeting_link': meetingLink,
      'event_type': eventType,
      'participants': participants.map((p) => p.id).toList(),
      'reminder_before': reminderBefore,
      'color': color,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory EventModel.fromEntity(EventEntity entity) => EventModel(
    id: entity.id,
    title: entity.title,
    description: entity.description,
    start: entity.start,
    end: entity.end,
    meetingLink: entity.meetingLink,
    eventType: entity.eventType,
    participants: entity.participants,
    reminderBefore: entity.reminderBefore,
    color: entity.color,
  );
}