import 'package:dartz/dartz.dart';
import 'package:my_app/event_management/core/errors/failures.dart';

import 'package:my_app/event_management/core/usecases/usecase.dart';

import '../repositories/event_repository.dart';

class DeleteEvent implements UseCase<bool, int> {
  final EventRepository _repo;

  const DeleteEvent(this._repo);

  @override
  Future<Either<Failure, bool>> call(int id) => _repo.deleteEvent(id);
}