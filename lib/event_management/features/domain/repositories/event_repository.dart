import 'package:dartz/dartz.dart';

import 'package:my_app/event_management/core/errors/failures.dart';

import '../entities/event_entity.dart';

/// The ONLY contract the domain / bloc layer knows about.
/// Concrete implementation lives in data/repositories/.
abstract class EventRepository {
  /// Fetch **all** events.  Optional [start] / [end] filters (ISO-8601 strings).
  Future<Either<Failure, List<EventEntity>>> getEvents({
    String? start,
    String? end,
  });

  /// Create a new event.  Returns the saved entity (with the server-assigned id).
  Future<Either<Failure, EventEntity>> createEvent(EventEntity event);

  /// Overwrite an existing event.
  Future<Either<Failure, EventEntity>> updateEvent(EventEntity event);

  /// Delete by PK.  Returns [Right(true)] on success.
  Future<Either<Failure, bool>> deleteEvent(int id);
}