import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'secure_storage_service.dart';

class ApiClient {
  ApiClient._internal() {
    _init();
  }

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  final SecureStorageService _storage = SecureStorageService();
  late final Dio _dio;

  CancelToken _masterCancelToken = CancelToken();

  /// ================= AUTH STATE =================
  bool _isLoggedOut = false;
  bool _isRefreshing = false;
  Future<String?>? _refreshFuture;


  bool _hasValidSession = false;


  bool get isAuthenticated => _hasValidSession;

  static const String _base =
  String.fromEnvironment('BASE_URL', defaultValue: 'http://localhost:8000');

  String get baseAccounts => "$_base/api/accounts/crm";
  String get baseEmployee => "$_base/api/employee/crm";
  String get baseLeaves => "$_base/api/leaves";

  // =========================================================
  // NEW: INITIALIZE AUTH
  // =========================================================
  Future<void> initializeAuth() async {
    final token = await _storage.readToken();

    if (token != null && token.isNotEmpty) {
      _hasValidSession = true;
      _isLoggedOut = false;
    } else {
      _hasValidSession = false;
      _isLoggedOut = true;
    }
  }

  // =========================================================
  // INIT
  // =========================================================
  void _init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _base,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {"Content-Type": "application/json"},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            if (_isLoggedOut) {
              return handler.reject(
                DioException(
                  requestOptions: options,
                  error: "Blocked: user logged out",
                  type: DioExceptionType.cancel,
                ),
              );
            }

            final token = await _storage.readToken();

            final isAuthFree =
                options.path.contains('login') ||
                    options.path.contains('refresh') ||
                    options.path.contains('register');

            if (!isAuthFree && (token == null || token.isEmpty)) {
              return handler.reject(
                DioException(
                  requestOptions: options,
                  error: "No auth token",
                  type: DioExceptionType.cancel,
                ),
              );
            }

            if (token != null && token.isNotEmpty) {
              options.headers["Authorization"] = "Bearer $token";
            }

            if (kDebugMode) {
              debugPrint(" ${options.method} ${options.uri}");
            }

            handler.next(options);
          } catch (e) {
            handler.reject(
              DioException(
                requestOptions: options,
                error: e.toString(),
              ),
            );
          }
        },

        onError: (error, handler) async {
          final statusCode = error.response?.statusCode;

          final isAuthFree =
              error.requestOptions.path.contains('login') ||
                  error.requestOptions.path.contains('refresh');

          if (statusCode == 401 && !_isLoggedOut && !isAuthFree) {
            final newToken = await _refreshAccessToken();

            if (newToken != null) {
              try {
                final opts = error.requestOptions;
                opts.headers["Authorization"] = "Bearer $newToken";
                final cloneResponse = await _dio.fetch(opts);
                return handler.resolve(cloneResponse);
              } catch (_) {}
            }

            if (kDebugMode) {
              debugPrint(" Refresh failed. Forcing logout.");
            }

            await logout();
          }

          handler.next(error);
        },
      ),
    );
  }

  // =========================================================
  // REFRESH FLOW
  // =========================================================
  Future<String?> _refreshAccessToken() async {
    if (_isLoggedOut) return null;

    if (_isRefreshing) {
      return _refreshFuture;
    }

    _isRefreshing = true;
    _refreshFuture = _performTokenRefresh();

    final token = await _refreshFuture;
    _isRefreshing = false;

    return token;
  }

  Future<String?> _performTokenRefresh() async {
    try {
      final refresh = await _storage.readRefreshToken();

      if (refresh == null || refresh.isEmpty) {
        return null;
      }

      if (kDebugMode) {
        debugPrint(" Attempting token refresh...");
      }

      final response = await Dio().post(
        "$baseAccounts/token/refresh/",
        data: {"refresh": refresh},
      );

      final newAccess = response.data["access"];
      if (newAccess == null) return null;

      await _storage.saveToken(newAccess);

      _hasValidSession = true;

      if (kDebugMode) {
        debugPrint(" Token refreshed");
      }

      return newAccess;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(" Refresh error: $e");
      }
      return null;
    }
  }

  // =========================================================
  // LOGOUT
  // =========================================================
  Future<void> logout() async {
    if (_isLoggedOut) return;

    _isLoggedOut = true;
    _hasValidSession = false;

    _masterCancelToken.cancel("User logged out");
    _masterCancelToken = CancelToken();

    await _storage.clearTokens();

    if (kDebugMode) {
      debugPrint(" Session destroyed. All calls blocked.");
    }
  }

  // =========================================================
  // GET MAP
  // =========================================================
  Future<Map<String, dynamic>> get(
      String url, {
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      if (_isLoggedOut) {
        throw ApiException(401, "User logged out");
      }

      final response = await _dio.get(
        url,
        queryParameters: queryParameters,
        cancelToken: _masterCancelToken,
      );

      return _parseMap(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // =========================================================
  // GET LIST
  // =========================================================
  Future<List<dynamic>> getList(
      String url, {
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      if (_isLoggedOut) {
        throw ApiException(401, "User logged out");
      }

      final response = await _dio.get(
        url,
        queryParameters: queryParameters,
        cancelToken: _masterCancelToken,
      );

      if (response.data is List) return response.data as List<dynamic>;

      throw ApiException(500, "Expected list response");
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // =========================================================
  // POST
  // =========================================================
  Future<Map<String, dynamic>> post(
      String url, {
        Object? body,
      }) async {
    try {
      if (_isLoggedOut) {
        throw ApiException(401, "User logged out");
      }

      final response = await _dio.post(
        url,
        data: body ?? {},
        cancelToken: _masterCancelToken,
      );

      return _parseMap(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Map<String, dynamic> _parseMap(dynamic data) {
    if (data == null) return {};
    if (data is Map<String, dynamic>) return data;
    if (data is String) return jsonDecode(data);
    return {};
  }

  ApiException _handleError(DioException e) {
    if (CancelToken.isCancel(e)) {
      return ApiException(499, "Request cancelled");
    }

    if (e.response != null) {
      return ApiException(
        e.response!.statusCode ?? 500,
        e.response!.data.toString(),
      );
    }

    return ApiException(500, e.message ?? "Network error");
  }
}

class ApiException implements Exception {
  final int code;
  final String message;

  ApiException(this.code, this.message);

  @override
  String toString() => "ApiException($code): $message";
}