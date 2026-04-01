import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:my_app/event_management/core/errors/failures.dart';
import '../../domain/entity/notification_entity.dart';
import '../../domain/repository/notification_repository.dart';
import '../datasource/notification_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationDataSource dataSource;

  NotificationRepositoryImpl(this.dataSource);

  Failure _mapException(Object e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return const NetworkFailure();
      }
      final msg = e.response?.data?['detail'] as String? ??
          e.message ??
          'Server error';
      return ServerFailure(msg, statusCode: e.response?.statusCode);
    }
    return ServerFailure(e.toString());
  }

  @override
  Future<Either<Failure, List<AppNotification>>> getNotifications({
    bool unreadOnly = false,
  }) async {
    try {
      final result =
      await dataSource.getNotifications(unreadOnly: unreadOnly);
      return Right(result);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      final count = await dataSource.getUnreadCount();
      return Right(count);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, void>> markRead(String id) async {
    try {
      await dataSource.markRead(id);
      return const Right(null);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, int>> markAllRead() async {
    try {
      final count = await dataSource.markAllRead();
      return Right(count);
    } catch (e) {
      return Left(_mapException(e));
    }
  }
}