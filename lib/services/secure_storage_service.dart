import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final SecureStorageService _instance =
  SecureStorageService._internal();

  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  // =========================
  // STORAGE KEYS
  // =========================
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userKey = 'user_json';
  static const String _roleKey = 'user_role';
  static const String _companyIdKey = 'company_id';

  // =========================
  // SINGLE STORAGE (ALL PLATFORMS)
  // =========================
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
    webOptions: WebOptions(
      dbName: 'my_app_secure_storage',
      publicKey: 'my_app_key',
    ),
  );

  // =========================
  // TOKEN
  // =========================

  Future<void> saveToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  Future<String?> readToken() async {
    return _storage.read(key: _accessTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  Future<String?> readRefreshToken() async {
    return _storage.read(key: _refreshTokenKey);
  }

  // =========================
  // USER
  // =========================

  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  Future<String?> readUserId() async {
    return _storage.read(key: _userIdKey);
  }

  Future<void> saveUser(Map<String, dynamic> user) async {
    await _storage.write(
      key: _userKey,
      value: jsonEncode(user),
    );
  }

  Future<Map<String, dynamic>?> readUser() async {
    final jsonStr = await _storage.read(key: _userKey);
    if (jsonStr == null) return null;

    try {
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveRole(String role) async {
    await _storage.write(key: _roleKey, value: role);
  }

  Future<String?> readRole() async {
    return _storage.read(key: _roleKey);
  }

  // =========================
  // COMPANY
  // =========================

  Future<void> saveCompanyId(String companyId) async {
    await _storage.write(key: _companyIdKey, value: companyId);
  }

  Future<String?> readCompanyId() async {
    return _storage.read(key: _companyIdKey);
  }

  // =========================
  // CLEAR
  // =========================

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
