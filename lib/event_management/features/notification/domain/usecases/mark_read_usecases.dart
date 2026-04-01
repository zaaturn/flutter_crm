import 'package:dartz/dartz.dart';
import 'package:my_app/event_management/core/errors/failures.dart';
import '../repository/notification_repository.dart';

class MarkReadUseCase {
  final NotificationRepository repository;

  MarkReadUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) => repository.markRead(id);

  Future<Either<Failure, int>> markAll() => repository.markAllRead();
}
