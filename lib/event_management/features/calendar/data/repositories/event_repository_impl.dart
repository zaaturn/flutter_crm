import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import 'package:my_app/event_management/features/domain/entities/event_entity.dart';
import 'package:my_app/event_management/features/domain/repositories/event_repository.dart';

import '../datasources/event_remote_datasource.dart';
import 'package:my_app/event_management/features/calendar/data/models/event_models.dart';


/// The only class that knows about both [EventRemoteDatasource] and [EventRepository].
/// Its job: call the datasource, catch typed exceptions, return Either.
class EventRepositoryImpl implements EventRepository {
  final EventRemoteDatasource _datasource;

  const EventRepositoryImpl(this._datasource);

  // ────────────────────────────────────────
  @override
  Future<Either<Failure, List<EventEntity>>> getEvents({
    String? start,
    String? end,
  }) async {
    try {
      final models = await _datasource.fetchEvents(start: start, end: end);
      return Right(models); // EventModel IS-A EventEntity → no explicit cast
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(errors: e.errors));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on Exception catch (e) {
      return Left(ParseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, EventEntity>> createEvent(EventEntity event) async {
    try {
      final model = await _datasource.createEvent(EventModel.fromEntity(event));
      return Right(model);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(errors: e.errors));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on Exception catch (e) {
      return Left(ParseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, EventEntity>> updateEvent(EventEntity event) async {
    try {
      final model = await _datasource.updateEvent(EventModel.fromEntity(event));
      return Right(model);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(errors: e.errors));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on Exception catch (e) {
      return Left(ParseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteEvent(int id) async {
    try {
      final result = await _datasource.deleteEvent(id);
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on Exception catch (e) {
      return Left(ParseFailure(message: e.toString()));
    }
  }
}