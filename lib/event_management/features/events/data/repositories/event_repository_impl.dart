import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:my_app/event_management/core/errors/failures.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/event_repository.dart';
import '../datasources/event_remote_datasource.dart';
import '../datasources/event_local_datasource.dart';
import '../models/event_model.dart';

class EventRepositoryImpl implements EventRepository {
  final EventRemoteDataSource remote;
  final EventLocalDataSource local;

  EventRepositoryImpl(this.remote, this.local);

  Future<bool> get _hasConnection async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  /// Remote/cache layers use [EventModel]; domain code often passes plain [Event]
  /// (e.g. after [Event.copyWith]).
  EventModel _asEventModel(Event event) {
    if (event is EventModel) return event;
    return EventModel(
      id: event.id,
      title: event.title,
      description: event.description,
      startTime: event.startTime,
      endTime: event.endTime,
      isAllDay: event.isAllDay,
      type: event.type,
      colorOverride: event.colorOverride,
      meetingLink: event.meetingLink,
      location: event.location,
      recurrence: event.recurrence,
      recurrenceEnd: event.recurrenceEnd,
      participants: event.participants,
      reminders: event.reminders,
      createdBy: event.createdBy,
      createdAt: event.createdAt,
      updatedAt: event.updatedAt,
    );
  }

  Failure _mapException(Object e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return const NetworkFailure();
      }
      final statusCode = e.response?.statusCode;
      final message = e.response?.data?['detail'] as String? ?? e.message ?? 'Server error';
      return ServerFailure(message, statusCode: statusCode);
    }
    return ServerFailure(e.toString());
  }

  @override
  Future<Either<Failure, List<Event>>> getEventsInRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      if (!await _hasConnection) {
        final cached = await local.getCachedEvents();
        return Right(cached.where((e) =>
        e.startTime.isAfter(startDate.subtract(const Duration(days: 1))) &&
            e.endTime.isBefore(endDate.add(const Duration(days: 1)))
        ).toList());
      }
      final events = await remote.getEventsInRange(
        startDate: startDate,
        endDate: endDate,
      );
      await local.cacheEvents(events);
      return Right(events);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, List<Event>>> getTodayEvents() async {
    try {
      final events = await remote.getTodayEvents();
      return Right(events);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, List<Event>>> getUpcomingEvents({int limit = 10}) async {
    try {
      final events = await remote.getUpcomingEvents(limit: limit);
      return Right(events);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, List<Event>>> getMissedEvents({int limit = 10}) async {
    try {
      final events = await remote.getMissedEvents(limit: limit);
      return Right(events);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, Event>> getEventById(String id) async {
    try {
      final event = await remote.getEventById(id);
      return Right(event);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, Event>> createEvent(Event event) async {
    try {
      final model = _asEventModel(event);
      final created = await remote.createEvent(model);
      await local.cacheEvent(created);
      return Right(created);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, Event>> updateEvent(Event event) async {
    try {
      final model = _asEventModel(event);
      final updated = await remote.updateEvent(model);
      await local.cacheEvent(updated);
      return Right(updated);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEvent(String id) async {
    try {
      await remote.deleteEvent(id);
      await local.removeEvent(id);
      return const Right(null);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, List<Event>>> searchEvents({
    required String query,
    String? eventType,
    DateTime? startDate,
    DateTime? endDate,
    String? participantId,
  }) async {
    try {
      final events = await remote.searchEvents(
        query: query,
        eventType: eventType,
        startDate: startDate,
        endDate: endDate,
        participantId: participantId,
      );
      return Right(events);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, Event>> addParticipant({
    required String eventId,
    required String userId,
  }) async {
    try {
      final event = await remote.addParticipant(
        eventId: eventId,
        userId: userId,
      );
      return Right(event);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, void>> removeParticipant({
    required String eventId,
    required String userId,
  }) async {
    try {
      await remote.removeParticipant(eventId: eventId, userId: userId);
      return const Right(null);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, Event>> acceptEventInvite(String eventId) async {
    try {
      final updated = await remote.acceptEventInvite(eventId);
      await local.cacheEvent(updated);
      return Right(updated);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, Event>> declineEventInvite(String eventId) async {
    try {
      final updated = await remote.declineEventInvite(eventId);
      await local.cacheEvent(updated);
      return Right(updated);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<List<Event>> getCachedEvents() => local.getCachedEvents();

  @override
  Future<void> cacheEvents(List<Event> events) async {
    final models = events.cast<EventModel>();
    await local.cacheEvents(models);
  }
}