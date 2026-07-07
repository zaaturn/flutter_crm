import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'secure_storage_service.dart';
import 'package:my_app/core/auth/auth_session_redirect.dart';
import 'package:my_app/core/auth/jwt_utils.dart';
import 'package:my_app/auth/profile_remote_sync.dart';

class ApiClient {

  ApiClient._internal() {
    _init();
    _checkInitialAuth();
    _startAutoRefresh();
  }
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  static const String _baseRaw = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://192.168.1.13:8000',
  );

  /// Base URL with trailing slashes stripped (avoids `//api/...` URLs).
  String get _rootBase => _baseRaw.replaceAll(RegExp(r'/+$'), '');

  // --- Dependencies & State ---
  final SecureStorageService _storage = SecureStorageService();
  late final Dio _dio;
  CancelToken _masterCancelToken = CancelToken();
  bool _isRefreshing = false;
  Future<String?>? _refreshingFuture;
  Timer? _autoRefreshTimer;
  Timer? _accessExpiryTimer;

  // --- GLOBAL LOADER ---
  static final ValueNotifier<bool> loader = ValueNotifier<bool>(false);
  static void showLoader() => loader.value = true;
  static void hideLoader() => loader.value = false;

  // --- AUTH STATE ---
  bool _isAuthenticated = false;

  // This synchronous getter fixes your BLoC errors
  bool get isAuthenticated => _isAuthenticated;

  /// Allows non-Dio login/logout flows to keep auth state in sync.
  void forceAuthenticated() {
    _isAuthenticated = true;
    _startAutoRefresh();
    unawaited(() async {
      final token = await _storage.readToken();
      if (token != null && token.isNotEmpty) {
        _scheduleAccessExpiryCheck(token);
      }
    }());
  }

  void forceUnauthenticated() => _isAuthenticated = false;

  /// Shared [Dio] for feature modules (e.g. event management) that use `/api/...` paths.
  Dio get dio => _dio;

  Future<void> _checkInitialAuth() async {
    final token = await _storage.readToken();
    _isAuthenticated = token != null && token.isNotEmpty && !JwtUtils.isExpired(token);
    if (_isAuthenticated) {
      _scheduleAccessExpiryCheck(token!);
    } else if (token != null && token.isNotEmpty && JwtUtils.isExpired(token)) {
      unawaited(ensureSessionValid(redirectOnFailure: false));
    }
  }

  void _scheduleAccessExpiryCheck(String accessToken) {
    _accessExpiryTimer?.cancel();
    final exp = JwtUtils.expiry(accessToken);
    if (exp == null) return;

    final delay = exp.difference(DateTime.now());
    if (delay.isNegative) {
      unawaited(ensureSessionValid(redirectOnFailure: true));
      return;
    }

    _accessExpiryTimer = Timer(delay + const Duration(seconds: 1), () {
      unawaited(ensureSessionValid(redirectOnFailure: true));
    });
  }

  /// Validates access/refresh JWT expiry and refreshes or redirects to login.
  Future<bool> ensureSessionValid({bool redirectOnFailure = false}) async {
    final access = await _storage.readToken();
    final refresh = await _storage.readRefreshToken();

    if (refresh == null || refresh.isEmpty) {
      if (access != null &&
          access.isNotEmpty &&
          !JwtUtils.isExpired(access)) {
        _isAuthenticated = true;
        _scheduleAccessExpiryCheck(access);
        return true;
      }
      if (redirectOnFailure &&
          access != null &&
          access.isNotEmpty &&
          JwtUtils.isExpired(access)) {
        await _handleSessionExpired();
      }
      return false;
    }

    if (JwtUtils.isExpired(refresh)) {
      if (redirectOnFailure) await _handleSessionExpired();
      return false;
    }

    final accessExpired =
        access != null && access.isNotEmpty && JwtUtils.isExpired(access);
    if (access != null && access.isNotEmpty && !accessExpired) {
      _isAuthenticated = true;
      _scheduleAccessExpiryCheck(access);
      return true;
    }

    return refreshSession(redirectOnFailure: redirectOnFailure);
  }

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    // Refresh in the background so users don't randomly hit an expired access token.
    // The 401-interceptor remains as a safety net.
    _autoRefreshTimer = Timer.periodic(const Duration(minutes: 4), (_) async {
      try {
        final refresh = await _storage.readRefreshToken();
        if (refresh == null || refresh.isEmpty) return;
        await refreshSession(redirectOnFailure: true);
      } catch (_) {
        // Ignore: background refresh should never crash the app.
      }
    });
    unawaited(ensureSessionValid(redirectOnFailure: false));
  }

  /// Single-flight token refresh shared by interceptors, timers, and app resume.
  Future<String?> _refreshAccessToken({bool showLoading = false}) {
    final inFlight = _refreshingFuture;
    if (inFlight != null) return inFlight;

    _isRefreshing = true;
    _refreshingFuture = () async {
      if (showLoading) ApiClient.showLoader();
      try {
        return await _performTokenRefresh();
      } finally {
        if (showLoading) ApiClient.hideLoader();
      }
    }();

    return _refreshingFuture!.whenComplete(() {
      _isRefreshing = false;
      _refreshingFuture = null;
    });
  }

  // --- Endpoints ---
  String get baseAccounts => '$_rootBase/api/accounts/crm';
  String get baseEmployee => '$_rootBase/api/employee/crm';
  String get baseLeaves => '$_rootBase/api/leaves';

  // --- Initialization & Interceptors ---
  void _init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _rootBase,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        responseType: ResponseType.json,
        headers: {"Accept": "application/json"},
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
        ),
      );
    }

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final isAuthFree = options.path.contains('login') ||
                options.path.contains('refresh');

            var token = await _storage.readToken();

            if (!isAuthFree &&
                token != null &&
                token.isNotEmpty &&
                JwtUtils.isExpired(token)) {
              try {
                token = await _refreshAccessToken();
              } catch (_) {
                token = null;
              }
            }

            if ((token == null || token.isEmpty) && !isAuthFree) {
              final refresh = await _storage.readRefreshToken();
              if (refresh != null && refresh.isNotEmpty) {
                try {
                  token = await _refreshAccessToken();
                } catch (_) {
                  // Transient network error — fall through to reject below.
                }
              }
              if (token == null || token.isEmpty) {
                if (_isAuthenticated) {
                  await _handleSessionExpired();
                }
                return handler.reject(
                  DioException(
                    requestOptions: options,
                    error: AuthSessionRedirect.defaultMessage,
                  ),
                );
              }
            }

            if (token != null && token.isNotEmpty) {
              _isAuthenticated = true;
              _scheduleAccessExpiryCheck(token);
              options.headers["Authorization"] = "Bearer $token";
            }

            if (options.data is FormData) {
              options.headers["Content-Type"] = "multipart/form-data";
            }

            handler.next(options);
          } catch (e) {
            handler.reject(DioException(
              requestOptions: options,
              error: AuthSessionRedirect.displayMessage(e),
            ));
          }
        },
        onError: (error, handler) async {
          final statusCode = error.response?.statusCode;
          final isAuthFree = error.requestOptions.path.contains('login') ||
              error.requestOptions.path.contains('refresh');

          if (statusCode == 401 && !isAuthFree) {
            try {
              final newToken =
                  await _refreshAccessToken(showLoading: true);

              if (newToken != null && newToken.isNotEmpty) {
                _isAuthenticated = true;
                final opts = error.requestOptions;
                opts.headers["Authorization"] = "Bearer $newToken";
                try {
                  final response = await _dio.fetch(opts);
                  return handler.resolve(response);
                } catch (_) {
                  return handler.reject(error);
                }
              }

              _isAuthenticated = false;
              await _handleSessionExpired();
              return handler.reject(
                DioException(
                  requestOptions: error.requestOptions,
                    error: AuthSessionRedirect.defaultMessage,
                ),
              );
            } catch (e) {
              if (e is DioException && e.response?.statusCode == 401) {
                await _handleSessionExpired();
              }
              return handler.reject(
                DioException(
                  requestOptions: error.requestOptions,
                  error: AuthSessionRedirect.defaultMessage,
                  response: error.response,
                ),
              );
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<String?> _performTokenRefresh() async {
    final refreshToken = await _storage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return null;
    if (JwtUtils.isExpired(refreshToken)) return null;

    final refreshDio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      ),
    );

    try {
      final response = await refreshDio.post(
        "$baseAccounts/token/refresh/",
        data: {"refresh": refreshToken},
      );

      final data = response.data;
      if (data == null || data["access"] == null) return null;

      final newAccess = data["access"].toString();
      await _storage.saveToken(newAccess);
      if (data["refresh"] != null) {
        await _storage.saveRefreshToken(data["refresh"].toString());
      }

      _isAuthenticated = true;
      _scheduleAccessExpiryCheck(newAccess);
      await ProfileRemoteSync.syncFromServer();
      return newAccess;
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      if (code == 401) {
        return null;
      }
      rethrow;
    }
  }

  /// Clears auth state and sends the user to login when session is no longer valid.
  Future<void> _handleSessionExpired() async {
    final refresh = await _storage.readRefreshToken();
    final access = await _storage.readToken();
    final wasAuthenticated = _isAuthenticated;
    final hadSession = wasAuthenticated ||
        (refresh != null && refresh.isNotEmpty) ||
        (access != null && access.isNotEmpty);
    if (!hadSession) return;

    _isAuthenticated = false;
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
    _accessExpiryTimer?.cancel();
    _accessExpiryTimer = null;
    try {
      await _storage.clearAll();
    } catch (_) {}
    forceUnauthenticated();
    AuthSessionRedirect.onAuthFailure(
      statusCode: 401,
      notifyUser: wasAuthenticated,
    );
  }

  /// Explicitly refreshes the access token using the stored refresh token.
  /// Returns true if refresh succeeded (and access token updated).
  Future<bool> refreshSession({bool redirectOnFailure = false}) async {
    try {
      final refresh = await _storage.readRefreshToken();
      if (refresh == null || refresh.isEmpty) {
        if (redirectOnFailure) await _handleSessionExpired();
        return false;
      }
      if (JwtUtils.isExpired(refresh)) {
        if (redirectOnFailure) await _handleSessionExpired();
        return false;
      }
      final newToken = await _refreshAccessToken();
      final ok = newToken != null && newToken.isNotEmpty;
      if (!ok && redirectOnFailure) {
        await _handleSessionExpired();
      } else if (ok && newToken != null) {
        _scheduleAccessExpiryCheck(newToken);
      }
      return ok;
    } catch (e) {
      if (redirectOnFailure && e is DioException) {
        final code = e.response?.statusCode;
        if (code == 401) {
          await _handleSessionExpired();
        }
      }
      return false;
    }
  }

  // --- Public Methods ---
  Future<void> logout() async {
    _masterCancelToken.cancel("User logged out");
    _masterCancelToken = CancelToken();
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
    _accessExpiryTimer?.cancel();
    _accessExpiryTimer = null;
    await _storage.clearTokens();
    _isAuthenticated = false;
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
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return ApiException(408, "Request timeout.");
    }
    if (AuthSessionRedirect.isAuthFailure(
      e.error ?? e.response?.data,
      statusCode: e.response?.statusCode,
    )) {
      AuthSessionRedirect.onAuthFailure(
        error: e.error ?? e.response?.data,
        statusCode: e.response?.statusCode,
      );
      return ApiException(
        e.response?.statusCode ?? 401,
        AuthSessionRedirect.defaultMessage,
      );
    }
    return ApiException(
      e.response?.statusCode ?? 500,
      _friendlyMessage(e.response?.statusCode, e.response?.data, e.error),
    );
  }

  String _friendlyMessage(int? statusCode, dynamic data, dynamic error) {
    if (data is Map<String, dynamic>) {
      final detail = data['detail'] ?? data['message'] ?? data['error'];
      if (detail != null) return detail.toString();
    }
    if (data is String && data.isNotEmpty) {
      if (data.contains('<html') || data.contains('<!DOCTYPE')) {
        return 'Server error occurred. Please refresh the page.';
      }
      return data;
    }
    if (error != null && error.toString().isNotEmpty) {
      return error.toString();
    }
    switch (statusCode) {
      case 404:
        return 'Requested data not found.';
      case 500:
        return 'Server error occurred. Please refresh the page.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  Future<Map<String, dynamic>> get(String url,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(url,
          queryParameters: queryParameters,
          cancelToken: _masterCancelToken);
      return _parseMap(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List> getList(String url,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(url,
          queryParameters: queryParameters,
          cancelToken: _masterCancelToken);
      if (response.data is List) return response.data as List<dynamic>;
      throw ApiException(500, "Expected list response");
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> post(String url, {Object? body}) async {
    try {
      final response = await _dio.post(url,
          data: body ?? {}, cancelToken: _masterCancelToken);
      return _parseMap(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ===============================
  // PUT METHOD
  // ===============================
  Future<Map<String, dynamic>> put(
      String url, {
        Object? body,
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      final response = await _dio.put(
        url,
        data: body ?? {},
        queryParameters: queryParameters,
        cancelToken: _masterCancelToken,
      );
      return _parseMap(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ===============================
  // PATCH METHOD
  // ===============================
  Future<Map<String, dynamic>> patch(
    String url, {
    Object? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.patch(
        url,
        data: body ?? {},
        queryParameters: queryParameters,
        cancelToken: _masterCancelToken,
      );
      return _parseMap(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ===============================
  //  DELETE METHOD
  // ===============================
  Future<Map<String, dynamic>> delete(
      String url, {
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      final response = await _dio.delete(
        url,
        queryParameters: queryParameters,
        cancelToken: _masterCancelToken,
      );
      return _parseMap(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}

class ApiException implements Exception {
  final int code;
  final dynamic data;
  ApiException(this.code, this.data);

  String get message {
    if (data is Map<String, dynamic>) {
      final map = data as Map<String, dynamic>;
      return (map["detail"] ??
          map["message"] ??
          map["error"] ??
          "Something went wrong.")
          .toString();
    }
    return data?.toString() ?? "Something went wrong.";
  }

  @override
  String toString() => message;
}