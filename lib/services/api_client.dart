import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'secure_storage_service.dart';

class ApiClient {
  // --- Singleton Pattern ---
  ApiClient._internal() {
    _init();
    _checkInitialAuth(); // Check auth status on startup
  }
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  // --- Dependencies & State ---
  final SecureStorageService _storage = SecureStorageService();
  late final Dio _dio;
  CancelToken _masterCancelToken = CancelToken();
  bool _isRefreshing = false;

  // --- GLOBAL LOADER ---
  static final ValueNotifier<bool> loader = ValueNotifier<bool>(false);
  static void showLoader() => loader.value = true;
  static void hideLoader() => loader.value = false;

  // --- AUTH STATE ---
  bool _isAuthenticated = false;

  // This synchronous getter fixes your BLoC errors
  bool get isAuthenticated => _isAuthenticated;

  Future<void> _checkInitialAuth() async {
    final token = await _storage.readToken();
    _isAuthenticated = token != null && token.isNotEmpty;
  }

  // --- Endpoints ---
  static const String _base =
  String.fromEnvironment('BASE_URL', defaultValue: 'http://localhost:8000');

  String get baseAccounts => "$_base/api/accounts/crm";
  String get baseEmployee => "$_base/api/employee/crm";
  String get baseLeaves => "$_base/api/leaves";

  // --- Initialization & Interceptors ---
  void _init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _base,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        responseType: ResponseType.json,
        headers: {"Accept": "application/json"},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final isAuthFree = options.path.contains('login') ||
                options.path.contains('refresh');

            final token = await _storage.readToken();

            if ((token == null || token.isEmpty) && !isAuthFree) {
              _isAuthenticated = false;
              return handler.reject(
                DioException(
                  requestOptions: options,
                  error: "No auth token",
                ),
              );
            }

            if (token != null && token.isNotEmpty) {
              _isAuthenticated = true;
              options.headers["Authorization"] = "Bearer $token";
            }

            if (options.data is FormData) {
              options.headers["Content-Type"] = "multipart/form-data";
            }

            handler.next(options);
          } catch (e) {
            handler.reject(DioException(
                requestOptions: options, error: e.toString()));
          }
        },
        onError: (error, handler) async {
          final statusCode = error.response?.statusCode;
          final isAuthFree = error.requestOptions.path.contains('login') ||
              error.requestOptions.path.contains('refresh');

          if (statusCode == 401 && !isAuthFree) {
            if (_isRefreshing) {
              await Future.delayed(const Duration(milliseconds: 500));
              final token = await _storage.readToken();
              if (token != null) {
                final opts = error.requestOptions;
                opts.headers["Authorization"] = "Bearer $token";
                try {
                  final response = await _dio.fetch(opts);
                  return handler.resolve(response);
                } catch (e) {
                  return handler.reject(error);
                }
              }
            }

            _isRefreshing = true;
            ApiClient.showLoader();
            final newToken = await _performTokenRefresh();
            ApiClient.hideLoader();
            _isRefreshing = false;

            if (newToken != null) {
              _isAuthenticated = true;
              final opts = error.requestOptions;
              opts.headers["Authorization"] = "Bearer $newToken";
              try {
                final response = await _dio.fetch(opts);
                return handler.resolve(response);
              } catch (_) {
                return handler.reject(error);
              }
            } else {
              _isAuthenticated = false;
              await _storage.clearTokens();
              return handler.reject(
                DioException(
                  requestOptions: error.requestOptions,
                  error: "Session expired. Please login again.",
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
    try {
      final refreshToken = await _storage.readRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) return null;

      final refreshDio = Dio();
      final response = await refreshDio.post(
        "$baseAccounts/token/refresh/",
        data: {"refresh": refreshToken},
      );

      final data = response.data;
      if (data == null || data["access"] == null) return null;

      final newAccess = data["access"];
      await _storage.saveToken(newAccess);
      if (data["refresh"] != null)
        await _storage.saveRefreshToken(data["refresh"]);

      _isAuthenticated = true;
      return newAccess;
    } catch (e) {
      return null;
    }
  }

  // --- Public Methods ---
  Future<void> logout() async {
    _masterCancelToken.cancel("User logged out");
    _masterCancelToken = CancelToken();
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
    if (CancelToken.isCancel(e))
      return ApiException(499, "Request cancelled");
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return ApiException(408, "Request timeout.");
    }
    return ApiException(
        e.response?.statusCode ?? 500, e.response?.data ?? e.error);
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