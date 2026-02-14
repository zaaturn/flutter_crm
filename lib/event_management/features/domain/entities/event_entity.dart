
class EventEntity {
  final int? id;                 // null when creating a new event
  final String title;
  final String description;
  final DateTime start;
  final DateTime end;
  final String meetingLink;      // empty string = no link
  final String eventType;        // 'meeting' | 'call' | 'followup' | 'task'
  final List<int> participants;  // list of user-IDs (matches Django User PKs)
  final int reminderBefore;      // minutes

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
  });

  // ── Equality ──
  @override
  bool operator ==(Object other) {
    if (this == other) return true;
    if (other is! EventEntity) return false;
    return id == other.id &&
        title == other.title &&
        description == other.description &&
        start == other.start &&
        end == other.end &&
        meetingLink == other.meetingLink &&
        eventType == other.eventType &&
        _listEq(participants, other.participants) &&
        reminderBefore == other.reminderBefore;
  }

  @override
  int get hashCode => Object.hash(
    id, title, description, start, end,
    meetingLink, eventType, participants, reminderBefore,
  );

  /// Shallow copy with overrides.
  EventEntity copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? start,
    DateTime? end,
    String? meetingLink,
    String? eventType,
    List<int>? participants,
    int? reminderBefore,
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
  );
}

bool _listEq(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}