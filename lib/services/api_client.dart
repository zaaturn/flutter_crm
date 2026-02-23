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
  bool _isRefreshing = false;

  static const String _base =
  String.fromEnvironment('BASE_URL', defaultValue: 'http://localhost:8000');

  String get baseAccounts => "$_base/api/accounts/crm";
  String get baseEmployee => "$_base/api/employee/crm";
  String get baseLeaves => "$_base/api/leaves";

  // =========================================================
  // SIMPLE AUTH FLAG
  // =========================================================
  bool get isAuthenticated => true;

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
        // ================= REQUEST =================
        onRequest: (options, handler) async {
          try {
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
              debugPrint("${options.method} ${options.uri}");
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

        // ================= ERROR =================
        onError: (error, handler) async {
          final statusCode = error.response?.statusCode;

          final isAuthFree =
              error.requestOptions.path.contains('login') ||
                  error.requestOptions.path.contains('refresh');

          if (statusCode == 401 && !isAuthFree) {

            // If already refreshing, avoid duplicate calls
            if (_isRefreshing) {
              return handler.next(error);
            }

            _isRefreshing = true;

            final newToken = await _refreshAccessToken();

            _isRefreshing = false;

            if (newToken != null) {
              try {
                final opts = error.requestOptions;

                // Update header with new token
                opts.headers["Authorization"] = "Bearer $newToken";

                final response = await _dio.request(
                  opts.path,
                  data: opts.data,
                  queryParameters: opts.queryParameters,
                  options: Options(
                    method: opts.method,
                    headers: opts.headers,
                  ),
                );

                return handler.resolve(response);
              } catch (_) {
                await logout();
              }
            } else {
              await logout();
            }
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
    try {
      final refresh = await _storage.readRefreshToken();
      if (refresh == null || refresh.isEmpty) return null;

      final response = await Dio().post(
        "$baseAccounts/token/refresh/",
        data: {"refresh": refresh},
      );

      final newAccess = response.data["access"];
      final newRefresh = response.data["refresh"]; // 👈 important

      if (newAccess == null) return null;

      await _storage.saveToken(newAccess);


      if (newRefresh != null) {
        await _storage.saveRefreshToken(newRefresh);
      }

      return newAccess;
    } catch (_) {
      return null;
    }
  }

  // =========================================================
  // LOGOUT
  // =========================================================
  Future<void> logout() async {
    _masterCancelToken.cancel("User logged out");
    _masterCancelToken = CancelToken();
    await _storage.clearTokens();
  }

  // =========================================================
  // GET MAP
  // =========================================================
  Future<Map<String, dynamic>> get(
      String url, {
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
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

  // =========================================================
  // HELPERS
  // =========================================================
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