import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_client.dart';
import 'secure_storage_service.dart';

class AuthService {
  final SecureStorageService _storage = SecureStorageService();

  // =========================
  // BASE URL (WEB + MOBILE)
  // =========================
  static const String _base =
  String.fromEnvironment('BASE_URL', defaultValue: 'http://192.168.1.13:8000');

  static String get _accountsBase => "$_base/api/accounts/crm";

  // =========================
  // LOGIN
  // =========================
  Future<Map<String, dynamic>> login(
      String username,
      String password,
      ) async {
    // Prevent cross-user leakage (stale user_id/user_json/role from prior sessions).
    await _storage.clearAll();
    ApiClient().forceUnauthenticated();

    final response = await http.post(
      Uri.parse("$_accountsBase/login/"),
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
    await _storage.saveToken(data["access"]);
    await _storage.saveRefreshToken(data["refresh"]);
    ApiClient().forceAuthenticated();

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
          Uri.parse("$_accountsBase/logout/"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"refresh": refresh}),
        );
      } catch (_) {}
    }

    await _storage.clearAll();
    ApiClient().forceUnauthenticated();
  }
}
