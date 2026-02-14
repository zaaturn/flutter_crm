import 'package:dartz/dartz.dart';

import 'package:my_app/event_management/core/errors/failures.dart';

import 'package:my_app/event_management/core/usecases/usecase.dart';

import '../entities/event_entity.dart';
import '../repositories/event_repository.dart';

class UpdateEvent implements UseCase<EventEntity, EventEntity> {
  final EventRepository _repo;

  const UpdateEvent(this._repo);

  @override
  Future<Either<Failure, EventEntity>> call(EventEntity params) =>
      _repo.updateEvent(params);
}