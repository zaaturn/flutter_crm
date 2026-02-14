import 'package:dartz/dartz.dart';

import 'package:my_app/event_management/core/errors/failures.dart';

import '../entities/event_entity.dart';


abstract class EventRepository {

  Future<Either<Failure, List<EventEntity>>> getEvents({
    String? start,
    String? end,
  });

  Future<Either<Failure, EventEntity>> createEvent(EventEntity event);

  Future<Either<Failure, EventEntity>> updateEvent(EventEntity event);

  Future<Either<Failure, bool>> deleteEvent(int id);
}