import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  // LOADER NOTIFIER
  static final ValueNotifier<bool> loader = ValueNotifier(false);

  static void showLoader() {
    loader.value = true;
  }

  static void hideLoader() {
    loader.value = false;
  }

  static const String _base =
  String.fromEnvironment('BASE_URL', defaultValue: 'http://localhost:8000');

  String get baseAccounts => "$_base/api/accounts/crm";
  String get baseEmployee => "$_base/api/employee/crm";
  String get baseLeaves => "$_base/api/leaves";

  bool get isAuthenticated => true;

  void _init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _base,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 15),
        responseType: ResponseType.json,
        headers: {
          "Accept": "*/*",
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
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

            if (options.data is FormData) {
              options.headers["Content-Type"] = "multipart/form-data";
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

        onError: (error, handler) async {
          final statusCode = error.response?.statusCode;

          final isAuthFree =
              error.requestOptions.path.contains('login') ||
                  error.requestOptions.path.contains('refresh');

          if (statusCode == 401 && !isAuthFree) {
            if (_isRefreshing) {
              while (_isRefreshing) {
                await Future.delayed(const Duration(milliseconds: 100));
              }

              final token = await _storage.readToken();
              if (token != null) {
                final opts = error.requestOptions;
                opts.headers["Authorization"] = "Bearer $token";
                final response = await _dio.fetch(opts);
                return handler.resolve(response);
              }

              return handler.reject(error);
            }

            _isRefreshing = true;

            // SHOW LOADER
            ApiClient.showLoader();

            final newToken = await _performTokenRefresh();

            // HIDE LOADER
            ApiClient.hideLoader();

            _isRefreshing = false;

            if (newToken != null) {
              try {
                final opts = error.requestOptions;
                opts.headers["Authorization"] = "Bearer $newToken";
                final response = await _dio.fetch(opts);
                return handler.resolve(response);
              } catch (_) {
                return handler.reject(error);
              }
            } else {
              return handler.reject(error);
            }
          }

          handler.next(error);
        },
      ),
    );
  }

  Future<String?> _performTokenRefresh() async {
    try {
      final refreshToken = await _storage.readRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        return null;
      }

      final dio = Dio();

      final response = await dio.post(
        "$baseAccounts/token/refresh/",
        data: {
          "refresh": refreshToken,
        },
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );

      final data = response.data;

      if (data == null || data["access"] == null) {
        return null;
      }

      final newAccess = data["access"];
      final newRefresh = data["refresh"];

      await _storage.saveToken(newAccess);

      if (newRefresh != null) {
        await _storage.saveRefreshToken(newRefresh);
      }

      return newAccess;
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint("Token refresh failed: ${e.response?.data}");
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Unexpected refresh error: $e");
      }

      return null;
    }
  }

  Future<void> logout() async {
    _masterCancelToken.cancel("User logged out");
    _masterCancelToken = CancelToken();
    await _storage.clearTokens();
  }

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

      if (response.data is List) {
        return response.data as List<dynamic>;
      }

      throw ApiException(500, "Expected list response");
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

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

  Map<String, dynamic> _parseMap(dynamic data) {
    if (data == null) return {};
    if (data is Map<String, dynamic>) return data;
    if (data is String) return jsonDecode(data);
    return {};
  }

  ApiException _handleError(DioException e) {
    if (CancelToken.isCancel(e) || e.type == DioExceptionType.cancel) {
      throw e;
    }

    if (e.response != null) {
      return ApiException(
        e.response!.statusCode ?? 500,
        e.response!.data,
      );
    }

    return ApiException(500, e.message ?? "Network error");
  }
}

class ApiException implements Exception {
  final int code;
  final dynamic data;

  ApiException(this.code, this.data);

  String get message {
    if (data is Map<String, dynamic>) {
      final map = data as Map<String, dynamic>;

      if (map["detail"] != null) return map["detail"].toString();
      if (map["message"] != null) return map["message"].toString();
      if (map["error"] != null) return map["error"].toString();
    }

    if (data is String) {
      return data.replaceAll("{detail: ", "").replaceAll("}", "").trim();
    }

    return "Something went wrong.";
  }

  @override
  String toString() => message;
}