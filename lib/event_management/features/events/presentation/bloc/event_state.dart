import 'package:equatable/equatable.dart';
import '../../domain/entities/event.dart';

abstract class EventState extends Equatable {
  const EventState();
  @override
  List<Object?> get props => [];
}

class EventInitial extends EventState {}

class EventLoading extends EventState {}

class EventCreating extends EventState {}

class EventUpdating extends EventState {}

class EventDeleting extends EventState {}

class EventsLoaded extends EventState {
  final List<Event> events;
  const EventsLoaded(this.events);
  @override
  List<Object?> get props => [events];
}

class EventCreated extends EventState {
  final Event event;
  const EventCreated(this.event);
  @override
  List<Object?> get props => [event];
}

class EventUpdated extends EventState {
  final Event event;
  const EventUpdated(this.event);
  @override
  List<Object?> get props => [event];
}

class EventDeleted extends EventState {
  final String eventId;
  const EventDeleted(this.eventId);
  @override
  List<Object?> get props => [eventId];
}

class EventConflictDetected extends EventState {
  final List<Event> conflicting;
  final Event pendingEvent;
  final String message;
  const EventConflictDetected(this.conflicting, this.pendingEvent, {
    this.message = 'This event conflicts with existing events.',
  });
  @override
  List<Object?> get props => [conflicting, pendingEvent];
}

class EventSearchResults extends EventState {
  final List<Event> results;
  final String query;
  const EventSearchResults({required this.results, required this.query});
  @override
  List<Object?> get props => [results, query];
}

class EventError extends EventState {
  final String message;
  const EventError(this.message);
  @override
  List<Object?> get props => [message];
}
