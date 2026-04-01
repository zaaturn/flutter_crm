import 'package:dio/dio.dart';
import 'package:my_app/event_management/core/network/api_service.dart' show ApiEndpoints;
import 'package:my_app/services/api_client.dart';

/// Row from [UserSerializer] (id, username, email, …).
class DirectoryUser {
  final String id;
  final String username;
  final String? email;

  const DirectoryUser({required this.id, required this.username, this.email});

  factory DirectoryUser.fromJson(Map<String, dynamic> json) {
    return DirectoryUser(
      id: json['id']?.toString() ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String?,
    );
  }
}

class UserDirectoryPage {
  final List<DirectoryUser> users;
  final bool hasMore;

  const UserDirectoryPage({required this.users, required this.hasMore});
}

/// Calls `GET /api/users/all/?page=&search=` (paginated).
class UserDirectoryDatasource {
  Future<UserDirectoryPage> fetchPage({
    required int page,
    String search = '',
  }) async {
    final dio = ApiClient().dio;
    try {
      final response = await dio.get(
        ApiEndpoints.usersAll,
        queryParameters: <String, dynamic>{
          'page': page,
          if (search.trim().isNotEmpty) 'search': search.trim(),
        },
      );
      final data = response.data;
      if (data == null) {
        return const UserDirectoryPage(users: [], hasMore: false);
      }

      if (data is List) {
        final list = <DirectoryUser>[];
        for (final e in data) {
          if (e is Map) {
            list.add(
              DirectoryUser.fromJson(
                Map<String, dynamic>.from(
                  e.map((k, v) => MapEntry(k.toString(), v)),
                ),
              ),
            );
          }
        }
        list.removeWhere((u) => u.id.isEmpty);
        return UserDirectoryPage(users: list, hasMore: false);
      }

      if (data is! Map) {
        return const UserDirectoryPage(users: [], hasMore: false);
      }

      final rawMap = data;
      final map = Map<String, dynamic>.from(
        rawMap.map((k, v) => MapEntry(k.toString(), v)),
      );
      final raw = map['results'];
      final users = <DirectoryUser>[];
      if (raw is List) {
        for (final e in raw) {
          if (e is Map) {
            users.add(
              DirectoryUser.fromJson(
                Map<String, dynamic>.from(
                  e.map((k, v) => MapEntry(k.toString(), v)),
                ),
              ),
            );
          }
        }
      }
      users.removeWhere((u) => u.id.isEmpty);
      final next = map['next'];
      final hasMore = next != null && next.toString().isNotEmpty;
      return UserDirectoryPage(users: users, hasMore: hasMore);
    } on DioException catch (e) {
      final readable = _readableDirectoryError(e);
      throw DioException(
        requestOptions: e.requestOptions,
        response: e.response,
        type: e.type,
        error: readable,
        message: readable,
      );
    }
  }

  static String _readableDirectoryError(DioException e) {
    final code = e.response?.statusCode;
    final uri = e.requestOptions.uri.toString();
    final data = e.response?.data;
    if (data is String &&
        (data.contains('<!DOCTYPE') || data.contains('<html'))) {
      return 'Users list failed ($code). Request was:\n$uri\n'
          'This URL is not registered on the server (HTML error page). '
          'Set USERS_ALL_PATH or ApiEndpoints.usersAll to your real route '
          '(often /api/accounts/crm/users/all/).';
    }
    if (data is String && data.length > 200) {
      return 'Users list failed ($code). ${data.substring(0, 200)}…';
    }
    return e.message ?? 'Failed to load users';
  }
}
