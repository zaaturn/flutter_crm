import 'package:dartz/dartz.dart';
import 'package:my_app/event_management/core/errors/failures.dart';
import '../entity/notification_entity.dart';
import '../repository/notification_repository.dart';

class FetchNotificationsUseCase {
  final NotificationRepository repository;

  FetchNotificationsUseCase(this.repository);

  Future<Either<Failure, List<AppNotification>>> call({
    bool unreadOnly = false,
  }) =>
      repository.getNotifications(unreadOnly: unreadOnly);

  Future<Either<Failure, List<AppNotification>>> unreadOnly() =>
      repository.getNotifications(unreadOnly: true);

  Future<Either<Failure, int>> getUnreadCount() =>
      repository.getUnreadCount();
}
