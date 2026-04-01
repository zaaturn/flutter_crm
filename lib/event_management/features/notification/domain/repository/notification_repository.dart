import 'package:dartz/dartz.dart';
import 'package:my_app/event_management/core/errors/failures.dart';
import '../entity/notification_entity.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<AppNotification>>> getNotifications({
    bool unreadOnly,
  });
  Future<Either<Failure, int>> getUnreadCount();
  Future<Either<Failure, void>> markRead(String id);
  Future<Either<Failure, int>> markAllRead();
}
