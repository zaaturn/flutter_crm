import 'package:dartz/dartz.dart';
import 'package:my_app/event_management/core/errors/failures.dart';
import '../entities/event.dart';
import '../repositories/event_repository.dart';

// ── Params ────────────────────────────────────────────────────────────────────

class FetchEventsParams {
  final DateTime startDate;
  final DateTime endDate;
  const FetchEventsParams({required this.startDate, required this.endDate});
}

class CreateEventParams {
  final Event event;
  const CreateEventParams({required this.event});
}

class UpdateEventParams {
  final Event event;
  const UpdateEventParams({required this.event});
}

class DetectConflictParams {
  final Event newEvent;
  final List<Event> existing;
  const DetectConflictParams({required this.newEvent, required this.existing});
}

class SearchEventsParams {
  final String query;
  final String? eventType;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? participantId;
  const SearchEventsParams({
    required this.query,
    this.eventType,
    this.startDate,
    this.endDate,
    this.participantId,
  });
}

// ── Use Cases ─────────────────────────────────────────────────────────────────

class FetchEventsUseCase {
  final EventRepository repository;
  FetchEventsUseCase(this.repository);

  Future<Either<Failure, List<Event>>> call(FetchEventsParams params) =>
      repository.getEventsInRange(
        startDate: params.startDate,
        endDate: params.endDate,
      );
}

class GetEventByIdUseCase {
  final EventRepository repository;
  GetEventByIdUseCase(this.repository);

  Future<Either<Failure, Event>> call(String id) => repository.getEventById(id);
}

class CreateEventUseCase {
  final EventRepository repository;
  CreateEventUseCase(this.repository);

  Future<Either<Failure, Event>> call(CreateEventParams params) =>
      repository.createEvent(params.event);
}

class UpdateEventUseCase {
  final EventRepository repository;
  UpdateEventUseCase(this.repository);

  Future<Either<Failure, Event>> call(UpdateEventParams params) =>
      repository.updateEvent(params.event);
}

class DeleteEventUseCase {
  final EventRepository repository;
  DeleteEventUseCase(this.repository);

  Future<Either<Failure, void>> call(String eventId) =>
      repository.deleteEvent(eventId);
}

class SearchEventsUseCase {
  final EventRepository repository;
  SearchEventsUseCase(this.repository);

  Future<Either<Failure, List<Event>>> call(SearchEventsParams params) =>
      repository.searchEvents(
        query: params.query,
        eventType: params.eventType,
        startDate: params.startDate,
        endDate: params.endDate,
        participantId: params.participantId,
      );
}

class DetectConflictUseCase {
  List<Event> call(DetectConflictParams params) {
    return params.existing
        .where((e) => params.newEvent.conflictsWith(e))
        .toList();
  }
}

class AcceptEventInviteUseCase {
  final EventRepository repository;
  AcceptEventInviteUseCase(this.repository);

  Future<Either<Failure, Event>> call(String eventId) =>
      repository.acceptEventInvite(eventId);
}

class DeclineEventInviteUseCase {
  final EventRepository repository;
  DeclineEventInviteUseCase(this.repository);

  Future<Either<Failure, Event>> call(String eventId) =>
      repository.declineEventInvite(eventId);
}