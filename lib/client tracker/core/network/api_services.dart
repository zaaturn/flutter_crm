import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants/app_constant.dart';
import 'package:my_app/services/secure_storage_service.dart';

class ApiClient {

  // Singleton
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final String _base = AppConstants.baseUrl;
  final SecureStorageService _storage = SecureStorageService();

  final Duration _timeout = const Duration(seconds: 30);

  bool _isRefreshing = false;
  Future<String?>? _refreshingFuture;

  // GLOBAL LOADER
  static final ValueNotifier<bool> loader = ValueNotifier(false);

  static void showLoader() {
    loader.value = true;
  }

  static void hideLoader() {
    loader.value = false;
  }

  // ---------------------------------------------------------------------------
  // PUBLIC METHODS
  // ---------------------------------------------------------------------------

  Future<dynamic> get(String path, {Map<String, String>? queryParams}) {
    return _request("GET", path, queryParams: queryParams);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) {
    return _request("POST", path, body: jsonEncode(body));
  }

  Future<dynamic> postList(String path, List<Map<String, dynamic>> body) {
    return _request("POST", path, body: jsonEncode(body));
  }

  Future<dynamic> patch(String path, Map<String, dynamic> body) {
    return _request("PATCH", path, body: jsonEncode(body));
  }

  Future<dynamic> delete(String path) {
    return _request("DELETE", path);
  }

  // ---------------------------------------------------------------------------
  // CORE REQUEST LOGIC
  // ---------------------------------------------------------------------------

  Future<dynamic> _request(
      String method,
      String path, {
        Map<String, String>? queryParams,
        dynamic body,
      }) async {

    var uri = Uri.parse('$_base$path');

    if (queryParams != null) {
      uri = uri.replace(queryParameters: queryParams);
    }

    var headers = await _getHeaders();
    http.Response res;

    try {

      res = await _executeRequest(method, uri, headers, body);

      // TOKEN REFRESH
      if (res.statusCode == 401) {
        // If a refresh is already in progress, wait for it and retry once.
        if (_refreshingFuture != null) {
          final token = await _refreshingFuture!;
          if (token != null && token.isNotEmpty) {
            headers = await _getHeaders();
            res = await _executeRequest(method, uri, headers, body);
          } else {
            await _storage.clearTokens();
            throw ApiException(401, "Session expired. Please login again.");
          }
        } else {
          _isRefreshing = true;
          showLoader();
          _refreshingFuture = _refreshToken();
          final newToken = await _refreshingFuture!;
          hideLoader();
          _isRefreshing = false;
          _refreshingFuture = null;

          if (newToken != null && newToken.isNotEmpty) {
            headers = await _getHeaders();
            res = await _executeRequest(method, uri, headers, body);
          } else {
            await _storage.clearTokens();
            throw ApiException(401, "Session expired. Please login again.");
          }
        }
      }

      return _handleResponse(res);

    } on TimeoutException {
      throw ApiException(408, "Request timeout. Please try again.");
    } on SocketException {
      throw ApiException(503, "No internet connection.");
    } catch (e) {

      if (e is ApiException) rethrow;

      throw ApiException(
        500,
        "Something went wrong. Please try again later.",
      );
    }
  }

  // ---------------------------------------------------------------------------
  // HEADERS
  // ---------------------------------------------------------------------------

  Future<Map<String, String>> _getHeaders() async {

    final token = await _storage.readToken();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }

  // ---------------------------------------------------------------------------
  // TOKEN REFRESH
  // ---------------------------------------------------------------------------

  Future<String?> _refreshToken() async {

    try {

      final refresh = await _storage.readRefreshToken();

      if (refresh == null || refresh.isEmpty) return null;

      final res = await http.post(
        Uri.parse("$_base/api/accounts/crm/token/refresh/"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"refresh": refresh}),
      ).timeout(_timeout);

      if (res.statusCode == 200) {

        final data = jsonDecode(res.body);

        final newAccess = data["access"];
        final newRefresh = data["refresh"];

        await _storage.saveToken(newAccess);

        if (newRefresh != null) {
          await _storage.saveRefreshToken(newRefresh);
        }

        return newAccess;
      }

    } catch (_) {
      return null;
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // EXECUTE HTTP REQUEST
  // ---------------------------------------------------------------------------

  Future<http.Response> _executeRequest(
      String method,
      Uri uri,
      Map<String, String> headers,
      dynamic body,
      ) async {

    switch (method) {

      case "GET":
        return http.get(uri, headers: headers).timeout(_timeout);

      case "POST":
        return http.post(uri, headers: headers, body: body).timeout(_timeout);

      case "PATCH":
        return http.patch(uri, headers: headers, body: body).timeout(_timeout);

      case "DELETE":
        return http.delete(uri, headers: headers).timeout(_timeout);

      default:
        throw Exception("Unsupported HTTP method: $method");
    }
  }

  // ---------------------------------------------------------------------------
  // RESPONSE HANDLING
  // ---------------------------------------------------------------------------

  dynamic _handleResponse(http.Response res) {

    dynamic body;

    try {
      body = res.body.isNotEmpty ? jsonDecode(res.body) : {};
    } catch (_) {
      body = {};
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body;
    }

    throw ApiException(
      res.statusCode,
      _friendlyError(res.statusCode),
    );
  }

  // ---------------------------------------------------------------------------
  // FRIENDLY ERROR MESSAGES
  // ---------------------------------------------------------------------------

  String _friendlyError(int statusCode) {

    switch (statusCode) {

      case 400:
        return "Invalid request.";

      case 401:
        return "Session expired. Please login again.";

      case 403:
        return "You don't have permission to perform this action.";

      case 404:
        return "Something went wrong. Please refresh.";

      case 408:
        return "Request timeout. Please try again.";

      case 500:
        return "Server error. Please try again later.";

      case 503:
        return "Service unavailable. Please try later.";

      default:
        return "Something went wrong. Please try again later.";
    }
  }
}

// ---------------------------------------------------------------------------
// API EXCEPTION
// ---------------------------------------------------------------------------

class ApiException implements Exception {

  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}