import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants/app_constant.dart';
import 'package:my_app/services/secure_storage_service.dart';

class ApiClient {

  // Singleton instance
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final String _base = AppConstants.baseUrl;
  final SecureStorageService _storage = SecureStorageService();

  final Duration _timeout = const Duration(seconds: 30);

  bool _isRefreshing = false;

  // GLOBAL LOADER
  static final ValueNotifier<bool> loader = ValueNotifier(false);

  static void showLoader() {
    loader.value = true;
  }

  static void hideLoader() {
    loader.value = false;
  }

  // ---------------------------------------------------------------------------
  // Public Methods
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
  // Core Logic
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
      if (res.statusCode == 401 && !_isRefreshing) {

        _isRefreshing = true;

        showLoader(); // show buffering

        final newToken = await _refreshToken();

        hideLoader(); // hide buffering

        _isRefreshing = false;

        if (newToken != null) {

          headers = await _getHeaders();
          res = await _executeRequest(method, uri, headers, body);

        } else {

          await _storage.clearTokens();
          throw ApiException(401, "Session expired. Please login again.");

        }
      }

      return _handleResponse(res);

    } on TimeoutException {
      throw ApiException(408, 'Request timeout. Please check your connection.');
    } on SocketException {
      throw ApiException(503, 'No internet connection.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(500, 'Unexpected error: $e');
    }
  }

  // ---------------------------------------------------------------------------

  Future<Map<String, String>> _getHeaders() async {
    final String? token = await _storage.readToken();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // ---------------------------------------------------------------------------

  Future<String?> _refreshToken() async {

    try {

      final refresh = await _storage.readRefreshToken();

      if (refresh == null || refresh.isEmpty) return null;

      final res = await http.post(
        Uri.parse("$_base/accounts/crm/token/refresh/"),
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

  dynamic _handleResponse(http.Response res) {

    dynamic body;

    try {
      body = res.body.isNotEmpty ? jsonDecode(res.body) : {};
    } catch (_) {
      body = {'error': 'Could not decode server response'};
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body;
    }

    throw ApiException(res.statusCode, _parseError(body));
  }

  String _parseError(dynamic body) {

    if (body is Map) {

      if (body.containsKey('detail')) {
        return body['detail'].toString();
      }

      if (body.containsKey('message')) {
        return body['message'].toString();
      }

      if (body.containsKey('error')) {
        return body['error'].toString();
      }

    }

    return body.toString();
  }
}

// ---------------------------------------------------------------------------

class ApiException implements Exception {

  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}