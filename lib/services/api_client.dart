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

  static const String _base =
  String.fromEnvironment('BASE_URL', defaultValue: 'http://localhost:8000');

  String get baseAccounts => "$_base/api/accounts/crm";
  String get baseEmployee => "$_base/api/employee/crm";
  String get baseLeaves => "$_base/api/leaves";

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
          final token = await _storage.readToken();


          if ((token == null || token.isEmpty) && !options.path.contains('login')) {
            return handler.reject(
              DioException(
                requestOptions: options,
                error: "Request blocked: No auth token found.",
                type: DioExceptionType.cancel,
              ),
            );
          }

          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }

          if (kDebugMode) {
            debugPrint("➡️ ${options.method} ${options.uri}");
          }

          handler.next(options);
        },
        onError: (error, handler) async {

          if (error.response?.statusCode == 401) {
            debugPrint("⚠️ 401 Unauthorized detected. Wiping session...");
            await logout();
          }
          handler.next(error);
        },
      ),
    );
  }

  /// Call this specifically when the user clicks the "Logout" button
  Future<void> logout() async {
    _masterCancelToken.cancel("User logged out");

    _masterCancelToken = CancelToken();

    await _storage.clearTokens();

    debugPrint("🚫 All background API calls cancelled and tokens cleared.");
  }

  // =========================
  // UPDATED METHODS WITH CANCELTOKEN
  // =========================

  Future<Map<String, dynamic>> get(String url, {Map<String, dynamic>? queryParameters}) async {
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

  Future<List<dynamic>> getList(String url, {Map<String, dynamic>? queryParameters}) async {
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

  Future<Map<String, dynamic>> post(String url, {Object? body}) async {
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
    if (CancelToken.isCancel(e)) {
      return ApiException(499, "Request cancelled by user logout");
    }
    if (e.response != null) {
      return ApiException(e.response!.statusCode ?? 500, e.response!.data.toString());
    }
    return ApiException(500, e.message ?? "Network error");
  }
}

class ApiException implements Exception {
  final int code;
  final String message;
  ApiException(this.code, this.message);
}