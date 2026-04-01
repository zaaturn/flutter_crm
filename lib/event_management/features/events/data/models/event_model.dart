import 'package:my_app/event_management/core/entities/user.dart';
import 'package:my_app/event_management/core/utils/event_instant.dart';

import '../../domain/entities/event.dart';
import 'user_model.dart';

String _jsonString(
  Map<String, dynamic> json,
  String key, [
  String fallback = '',
]) {
  final v = json[key];
  if (v == null) return fallback;
  return v.toString();
}

String? _jsonStringOrNull(Map<String, dynamic> json, String key) {
  final v = json[key];
  if (v == null) return null;
  final s = v.toString();
  return s.isEmpty ? null : s;
}

DateTime? _jsonDate(Map<String, dynamic> json, String key) {
  final v = json[key];
  if (v == null) return null;
  if (v is String) {
    try {
      return EventInstant.parseApi(v);
    } catch (_) {
      return DateTime.tryParse(v)?.toUtc();
    }
  }
  return null;
}

class ParticipantModel extends Participant {
  const ParticipantModel({
    required super.id,
    required super.username,
    super.avatar,
    super.status,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    final userRaw = json['user'];
    if (userRaw is Map<String, dynamic>) {
      final u = userRaw;
      return ParticipantModel(
        id: u['id']?.toString() ?? '',
        username: u['username'] as String? ?? '',
        avatar: u['avatar'] as String?,
        status: json['status'] as String? ?? 'pending',
      );
    }
    if (json['user_id'] != null) {
      return ParticipantModel(
        id: json['user_id'].toString(),
        username: json['username'] as String? ?? '',
        avatar: json['avatar'] as String?,
        status: json['status'] as String? ?? 'pending',
      );
    }
    return ParticipantModel(
      id: '',
      username: '',
      status: json['status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() => {'user_id': id, 'status': status};
}

class EventReminderModel extends EventReminder {
  const EventReminderModel({required super.id, required super.minutesBefore});

  factory EventReminderModel.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic v, [int d = 0]) {
      if (v is int) return v;
      return int.tryParse(v?.toString() ?? '') ?? d;
    }

    return EventReminderModel(
      id: asInt(json['id']),
      minutesBefore: asInt(json['minutes_before']),
    );
  }

  Map<String, dynamic> toJson() => {'minutes_before': minutesBefore};
}

class EventModel extends Event {
  const EventModel({
    required super.id,
    required super.title,
    super.description,
    required super.startTime,
    required super.endTime,
    super.isAllDay,
    required super.type,
    super.colorOverride,
    super.meetingLink,
    super.location,
    super.recurrence,
    super.recurrenceEnd,
    super.participants,
    super.reminders,
    required super.createdBy,
    required super.createdAt,
    required super.updatedAt,
  });

  /// [mergeFrom] fills gaps when the API returns partial JSON (common on POST/PATCH).
  factory EventModel.fromJson(Map<String, dynamic> json, {Event? mergeFrom}) {
    final start =
        _jsonDate(json, 'start_time') ?? mergeFrom?.startTime ?? DateTime.now();
    final end =
        _jsonDate(json, 'end_time') ??
        mergeFrom?.endTime ??
        start.add(const Duration(hours: 1));

    final typeRaw =
        json['event_type'] ?? json['type'] ?? mergeFrom?.type.name ?? 'meeting';

    List<Participant> participants;
    final pList = json['participants'];
    if (pList is List) {
      try {
        participants = pList
            .map((p) => ParticipantModel.fromJson(p as Map<String, dynamic>))
            .toList();
      } catch (_) {
        participants = List<Participant>.from(mergeFrom?.participants ?? []);
      }
    } else {
      participants = List<Participant>.from(mergeFrom?.participants ?? []);
    }

    List<EventReminder> reminders;
    final rList = json['reminders'];
    if (rList is List) {
      try {
        reminders = rList
            .map((r) => EventReminderModel.fromJson(r as Map<String, dynamic>))
            .toList();
      } catch (_) {
        reminders = List<EventReminder>.from(mergeFrom?.reminders ?? []);
      }
    } else {
      reminders = List<EventReminder>.from(mergeFrom?.reminders ?? []);
    }

    final createdRaw = json['created_by'];
    final User createdBy = createdRaw is Map<String, dynamic>
        ? UserModel.fromJson(createdRaw)
        : mergeFrom?.createdBy ??
              const UserModel(id: '', username: '', email: '');

    return EventModel(
      id: _jsonString(json, 'id', mergeFrom?.id ?? ''),
      title: _jsonString(json, 'title', mergeFrom?.title ?? 'Untitled'),
      description:
          _jsonStringOrNull(json, 'description') ??
          mergeFrom?.description ??
          '',
      startTime: start,
      endTime: end,
      isAllDay: json['is_all_day'] as bool? ?? mergeFrom?.isAllDay ?? false,
      type: EventTypeExtension.fromString(typeRaw.toString()),
      colorOverride:
          _jsonStringOrNull(json, 'color') ?? mergeFrom?.colorOverride ?? '',
      meetingLink:
          _jsonStringOrNull(json, 'meeting_link') ?? mergeFrom?.meetingLink,
      location: _jsonStringOrNull(json, 'location') ?? mergeFrom?.location,
      recurrence: _parseRecurrence(
        _jsonStringOrNull(json, 'recurrence') ?? mergeFrom?.recurrence.name,
      ),
      recurrenceEnd:
          _jsonDate(json, 'recurrence_end') ?? mergeFrom?.recurrenceEnd,
      participants: participants,
      reminders: reminders,
      createdBy: createdBy,
      createdAt:
          _jsonDate(json, 'created_at') ??
          mergeFrom?.createdAt ??
          DateTime.now(),
      updatedAt:
          _jsonDate(json, 'updated_at') ??
          mergeFrom?.updatedAt ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'start_time': startTime.toIso8601String(),
    'end_time': endTime.toIso8601String(),
    'is_all_day': isAllDay,
    'event_type': type.name,
    'color': colorOverride,
    if (meetingLink != null) 'meeting_link': meetingLink,
    if (location != null) 'location': location,
    'recurrence': recurrence.name,
    if (recurrenceEnd != null)
      'recurrence_end': recurrenceEnd!.toIso8601String().split('T')[0],
    'participant_ids': participants.map((p) => p.id).toList(),
    'reminders': reminders
        .map(
          (r) => EventReminderModel(
            id: r.id,
            minutesBefore: r.minutesBefore,
          ).toJson(),
        )
        .toList(),
  };

  static RecurrenceRule _parseRecurrence(String? value) {
    if (value == null || value.isEmpty) return RecurrenceRule.none;
    return RecurrenceRule.values.firstWhere(
      (r) => r.name == value,
      orElse: () => RecurrenceRule.none,
    );
  }
}
