import 'package:my_app/event_management/features/domain/entities/event_entity.dart';


/// Thin DTO that lives in the **data** layer.
/// It knows JSON; the Entity does not.
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
          .map((e) => e as int)
          .toList(),
      reminderBefore: json['reminder_before'] as int,
    );
  }

  // ─────────────────────────────────────────────
  // Model → JSON   (for POST / PUT)
  // ─────────────────────────────────────────────
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'start': start.toUtc().toIso8601String(),
      'end': end.toUtc().toIso8601String(),

      'meeting_link': meetingLink,
      'event_type': eventType,
      'participants': participants,
      'reminder_before': reminderBefore,
    };

    // Only send id on updates
    if (id != null) map['id'] = id;

    return map;
  }

  // ─────────────────────────────────────────────
  // Entity → Model  (when the bloc passes an entity into a use-case)
  // ─────────────────────────────────────────────
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
  );
}