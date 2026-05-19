
import 'package:dio/dio.dart';
import 'package:my_app/services/secure_storage_service.dart';

class ApiClient {
  /// Host root only; paths in [ApiEndpoints] include the `/api` prefix so this matches [services.ApiClient].
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://192.168.1.13:8000',
  );

  static Dio create() {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    dio.interceptors.addAll([
      _AuthInterceptor(),
      _RetryInterceptor(dio),
      LogInterceptor(requestBody: true, responseBody: true),
    ]);

    return dio;
  }
}

class _AuthInterceptor extends Interceptor {
  final SecureStorageService _storage = SecureStorageService();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.readToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Attempt token refresh
      final refreshed = await _refreshToken();
      if (refreshed) {
        // Retry original request
        final newToken = await _storage.readToken();
        if (newToken != null && newToken.isNotEmpty) {
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        }
        try {
          final dio = Dio();
          final response = await dio.fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (_) {}
      }
    }
    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.readRefreshToken();
      if (refreshToken == null) return false;

      final dio = Dio(
        BaseOptions(
          baseUrl: ApiClient.baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      final response = await dio.post(
        '/api/accounts/crm/token/refresh/',
        data: {'refresh': refreshToken},
      );

      final access = response.data['access']?.toString();
      if (access == null || access.isEmpty) return false;
      await _storage.saveToken(access);
      final newRefresh = response.data['refresh']?.toString();
      if (newRefresh != null && newRefresh.isNotEmpty) {
        await _storage.saveRefreshToken(newRefresh);
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}

class _RetryInterceptor extends Interceptor {
  final Dio dio;
  _RetryInterceptor(this.dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      await Future.delayed(const Duration(seconds: 1));
      try {
        final response = await dio.fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        return handler.next(err);
      }
    }
    handler.next(err);
  }

  bool _shouldRetry(DioException err) =>
      err.type == DioExceptionType.connectionTimeout ||
          err.type == DioExceptionType.receiveTimeout;
}

// API endpoints constants
class ApiEndpoints {
  // Auth
  static const String login = '/api/auth/token/';
  static const String register = '/api/auth/register/';
  static const String tokenRefresh = '/api/accounts/crm/token/refresh/';
  static const String profile = '/api/auth/profile/';
  static const String users = '/api/auth/users/';


  /// Default matches [ApiClient.baseAccounts] pattern (`…/api/accounts/crm/…`).
  static const String usersAll = String.fromEnvironment(
    'USERS_ALL_PATH',
    defaultValue: '/api/accounts/crm/users/all/',
  );

  // Events
  static const String events = '/api/events/';
  static const String eventsRange = '/api/events/range/';
  static const String eventsToday = '/api/events/today/';
  static const String eventsUpcoming = '/api/events/upcoming/';
  static const String eventsMissed = '/api/events/missed/';

  // Notifications
  static const String notifications = '/api/notifications/';
  static const String markAllRead = '/api/notifications/mark-all-read/';

  // Reminders
  static const String reminders = '/api/reminders/';
}