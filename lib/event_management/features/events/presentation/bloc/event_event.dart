import 'package:equatable/equatable.dart';
import '../../domain/entities/event.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class EventEvent extends Equatable {
  const EventEvent();
  @override
  List<Object?> get props => [];
}

/// Server-driven updates (WebSocket / background sync).
class ExternalEventUpserted extends EventEvent {
  final Event event;
  const ExternalEventUpserted(this.event);
  @override
  List<Object?> get props => [event];
}

/// Server-driven deletes (WebSocket / background sync).
class ExternalEventDeleted extends EventEvent {
  final String eventId;
  const ExternalEventDeleted(this.eventId);
  @override
  List<Object?> get props => [eventId];
}

class FetchEventsRequested extends EventEvent {
  final DateTime startDate;
  final DateTime endDate;
  const FetchEventsRequested({required this.startDate, required this.endDate});
  @override
  List<Object?> get props => [startDate, endDate];
}

class LoadEventByIdRequested extends EventEvent {
  final String eventId;
  const LoadEventByIdRequested(this.eventId);
  @override
  List<Object?> get props => [eventId];
}

class CreateEventRequested extends EventEvent {
  final Event event;
  const CreateEventRequested({required this.event});
  @override
  List<Object?> get props => [event];
}

class UpdateEventRequested extends EventEvent {
  final Event event;
  const UpdateEventRequested({required this.event});
  @override
  List<Object?> get props => [event];
}

class DeleteEventRequested extends EventEvent {
  final String eventId;
  const DeleteEventRequested({required this.eventId});
  @override
  List<Object?> get props => [eventId];
}

class QuickCreateEvent extends EventEvent {
  final String title;
  final DateTime selectedDate;
  final String creatorId;
  const QuickCreateEvent({
    required this.title,
    required this.selectedDate,
    required this.creatorId,
  });
  @override
  List<Object?> get props => [title, selectedDate];
}

class ConflictConfirmed extends EventEvent {
  final Event event;
  const ConflictConfirmed({required this.event});
  @override
  List<Object?> get props => [event];
}

class SearchRequested extends EventEvent {
  final String query;
  final String? eventType;
  final DateTime? startDate;
  final DateTime? endDate;
  const SearchRequested({
    required this.query,
    this.eventType,
    this.startDate,
    this.endDate,
  });
}

class AcceptEventInviteRequested extends EventEvent {
  final String eventId;
  const AcceptEventInviteRequested(this.eventId);
  @override
  List<Object?> get props => [eventId];
}

class DeclineEventInviteRequested extends EventEvent {
  final String eventId;
  const DeclineEventInviteRequested(this.eventId);
  @override
  List<Object?> get props => [eventId];
}