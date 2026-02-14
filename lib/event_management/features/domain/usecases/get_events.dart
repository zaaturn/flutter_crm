import 'package:dartz/dartz.dart';

import 'package:my_app/event_management/core/errors/failures.dart';

import 'package:my_app/event_management/core/usecases/usecase.dart';

import '../entities/event_entity.dart';
import '../repositories/event_repository.dart';

/// Optional date-range filters.
class GetEventsParams {
  final String? start; // ISO-8601
  final String? end;   // ISO-8601

  const GetEventsParams({this.start, this.end});
}

class GetEvents implements UseCase<List<EventEntity>, GetEventsParams> {
  final EventRepository _repo;

  const GetEvents(this._repo);

  @override
  Future<Either<Failure, List<EventEntity>>> call(GetEventsParams params) =>
      _repo.getEvents(start: params.start, end: params.end);
}