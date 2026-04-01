import 'package:dartz/dartz.dart';
import 'package:my_app/event_management/core/errors/failures.dart';
import '../entities/event.dart';

abstract class EventRepository {
  Future<Either<Failure, List<Event>>> getEventsInRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<Either<Failure, List<Event>>> getTodayEvents();

  Future<Either<Failure, List<Event>>> getUpcomingEvents({int limit = 10});

  Future<Either<Failure, List<Event>>> getMissedEvents({int limit = 10});

  Future<Either<Failure, Event>> getEventById(String id);

  Future<Either<Failure, Event>> createEvent(Event event);

  Future<Either<Failure, Event>> updateEvent(Event event);

  Future<Either<Failure, void>> deleteEvent(String id);

  Future<Either<Failure, List<Event>>> searchEvents({
    required String query,
    String? eventType,
    DateTime? startDate,
    DateTime? endDate,
    String? participantId,
  });

  Future<Either<Failure, Event>> addParticipant({
    required String eventId,
    required String userId,
  });

  Future<Either<Failure, void>> removeParticipant({
    required String eventId,
    required String userId,
  });

  Future<Either<Failure, Event>> acceptEventInvite(String eventId);

  Future<Either<Failure, Event>> declineEventInvite(String eventId);

  // Local cache
  Future<List<Event>> getCachedEvents();
  Future<void> cacheEvents(List<Event> events);
}