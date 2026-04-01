import 'package:dio/dio.dart';
import 'package:my_app/event_management/core/network/api_service.dart';
import '../model/notification_model.dart';

abstract class NotificationDataSource {
  Future<List<NotificationModel>> getNotifications({bool unreadOnly});
  Future<int> getUnreadCount();
  Future<void> markRead(String id);
  Future<int> markAllRead();
}

class NotificationDataSourceImpl implements NotificationDataSource {
  final Dio _dio;

  NotificationDataSourceImpl(this._dio);

  @override
  Future<List<NotificationModel>> getNotifications({
    bool unreadOnly = false,
  }) async {
    final response = await _dio.get(
      ApiEndpoints.notifications,
      queryParameters: unreadOnly ? {'unread': 'true'} : null,
    );

    // Handles both paginated {results: [...]} and plain list responses
    final data = response.data;
    final list = data is List
        ? List<dynamic>.from(data)
        : (data['results'] as List<dynamic>);

    return list
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await _dio.get(
      '${ApiEndpoints.notifications}unread-count/',
    );
    return response.data['unread_count'] as int? ?? 0;
  }

  @override
  Future<void> markRead(String id) async {
    await _dio.post('${ApiEndpoints.notifications}$id/read/');
  }

  @override
  Future<int> markAllRead() async {
    final response = await _dio.post(ApiEndpoints.markAllRead);
    return response.data['marked_read'] as int? ?? 0;
  }
}