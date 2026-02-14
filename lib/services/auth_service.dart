import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import 'secure_storage_service.dart';

class AuthService {
  final SecureStorageService _storage = SecureStorageService();

  // =========================
  // BASE URL (WEB + MOBILE)
  // =========================
  static String get _base {
    if (kIsWeb) {
      return "http://localhost:8000/api/accounts/crm";
    }
    return "http://192.168.1.13:8000/api/accounts/crm";
  }

  static String get _notificationBase {
    if (kIsWeb) {
      return "http://localhost:8000/api/leaves";
    }
    return "http://192.168.1.13:8000/api/leaves";
  }

  // =========================
  // LOGIN
  // =========================
  Future<Map<String, dynamic>> login(
      String username,
      String password,
      ) async {
    final response = await http.post(
      Uri.parse("$_base/login/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception("Login failed");
    }

    final data = jsonDecode(response.body);

    // ─────────────────────────
    // SAVE AUTH DATA
    // ─────────────────────────
    await _storage.clearTokens();
    await _storage.saveToken(data["access"]);
    await _storage.saveRefreshToken(data["refresh"]);

    if (data["user"] != null) {
      await _storage.saveUser(data["user"]);
      await _storage.saveUserId(data["user"]["id"].toString());
    }

    if (data["role"] != null) {
      await _storage.saveRole(data["role"]);
    }


    return data;
  }

  // =========================
  // LOGOUT
  // =========================
  Future<void> logout() async {
    final refresh = await _storage.readRefreshToken();

    if (refresh != null && refresh.isNotEmpty) {
      try {
        await http.post(
          Uri.parse("$_base/logout/"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"refresh": refresh}),
        );
      } catch (_) {}
    }

    await _storage.clearAll();
  }
}
