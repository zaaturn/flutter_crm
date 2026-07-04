import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:my_app/auth/auth_session.dart';
import 'package:my_app/auth/profile_remote_sync.dart';
import 'package:my_app/core/auth/auth_session_redirect.dart';

import 'api_client.dart';
import 'secure_storage_service.dart';

class AuthService {
  final SecureStorageService _storage = SecureStorageService();

  // =========================
  // BASE URL (WEB + mobile)
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

    await ProfileRemoteSync.applyAuthPayload(data);
    AuthSessionRedirect.clearExpiryNotice();

    return data;
  }

  /// Refresh profile from server (same shape as login extensions).
  Future<AuthSession> fetchMe() => ProfileRemoteSync.fetchMe();

  Future<AuthSession?> readStoredSession() async {
    final raw = await _storage.readAuthSessionJson();
    return AuthSession.fromStorageString(raw);
  }

  Future<void> setActiveDashboard(ActiveDashboard dash) async {
    await _storage.saveActiveDashboard(dash.storageValue);
  }

  Future<ActiveDashboard?> readActiveDashboard() async {
    final s = await _storage.readActiveDashboard();
    return ActiveDashboardStorage.fromString(s);
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
