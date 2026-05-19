import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:my_app/auth/auth_session.dart';
import 'package:my_app/services/secure_storage_service.dart';

/// Loads `/me/` and persists role / `admin_modules` / superuser without depending on [ApiClient]
/// (avoids circular imports when the token refresh interceptor syncs profile).
class ProfileRemoteSync {
  ProfileRemoteSync._();

  static const String _base = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://192.168.1.13:8000',
  );

  static String get _accountsBase => '$_base/api/accounts/crm';

  /// Increments when stored auth session fields change; desktop sidebar listens to reload modules.
  static final ValueNotifier<int> authSessionEpoch = ValueNotifier<int>(0);

  static Future<void> applyAuthPayload(Map<String, dynamic> data) async {
    final storage = SecureStorageService();
    final session = AuthSession.fromJson(data);
    await storage.saveIsSuperuser(session.isSuperuser);
    await storage.saveAuthSessionJson(session.toStorageJson());
    await storage.saveAdminModulesJson(jsonEncode(session.adminModules));
    if (data['role'] != null) {
      await storage.saveRole(data['role'].toString());
    }
    authSessionEpoch.value++;
  }

  /// GET [me/] and persist. Throws on network or non-2xx.
  static Future<AuthSession> fetchMe() async {
    final storage = SecureStorageService();
    final token = await storage.readToken();
    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated');
    }
    final response = await http.get(
      Uri.parse('$_accountsBase/me/'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to load profile');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    await applyAuthPayload(data);
    return AuthSession.fromJson(data);
  }

  /// Best-effort profile sync (e.g. after token refresh). Swallows errors.
  static Future<void> syncFromServer() async {
    try {
      await fetchMe();
    } catch (_) {}
  }
}
