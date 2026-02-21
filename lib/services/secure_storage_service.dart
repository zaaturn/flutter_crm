import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageService {
  SecureStorageService._internal();
  static final SecureStorageService _instance =
  SecureStorageService._internal();
  factory SecureStorageService() => _instance;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userKey = 'user_json';
  static const String _roleKey = 'user_role';
  static const String _companyIdKey = 'company_id';

  final FlutterSecureStorage _secureStorage =
  const FlutterSecureStorage();

  SharedPreferences? _prefs;

  // =========================================================
  // INIT WEB PREFS (lazy load)
  // =========================================================
  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // =========================================================
  // GENERIC WRITE
  // =========================================================
  Future<void> _write(String key, String value) async {
    if (kIsWeb) {
      final prefs = await _getPrefs();
      await prefs.setString(key, value);
    } else {
      await _secureStorage.write(key: key, value: value);
    }
  }

  // =========================================================
  // GENERIC READ
  // =========================================================
  Future<String?> _read(String key) async {
    if (kIsWeb) {
      final prefs = await _getPrefs();
      return prefs.getString(key);
    } else {
      return _secureStorage.read(key: key);
    }
  }

  // =========================================================
  // TOKEN
  // =========================================================
  Future<void> saveToken(String token) async =>
      _write(_accessTokenKey, token);

  Future<String?> readToken() async =>
      _read(_accessTokenKey);

  Future<void> saveRefreshToken(String token) async =>
      _write(_refreshTokenKey, token);

  Future<String?> readRefreshToken() async =>
      _read(_refreshTokenKey);

  // =========================================================
  // USER
  // =========================================================
  Future<void> saveUserId(String userId) async =>
      _write(_userIdKey, userId);

  Future<String?> readUserId() async =>
      _read(_userIdKey);

  Future<void> saveUser(Map<String, dynamic> user) async =>
      _write(_userKey, jsonEncode(user));

  Future<Map<String, dynamic>?> readUser() async {
    final jsonStr = await _read(_userKey);
    if (jsonStr == null) return null;
    return jsonDecode(jsonStr);
  }

  Future<void> saveRole(String role) async =>
      _write(_roleKey, role);

  Future<String?> readRole() async =>
      _read(_roleKey);

  Future<void> saveCompanyId(String companyId) async =>
      _write(_companyIdKey, companyId);

  Future<String?> readCompanyId() async =>
      _read(_companyIdKey);

  // =========================================================
  // CLEAR
  // =========================================================
  Future<void> clearTokens() async {
    if (kIsWeb) {
      final prefs = await _getPrefs();
      await prefs.remove(_accessTokenKey);
      await prefs.remove(_refreshTokenKey);
    } else {
      await _secureStorage.delete(key: _accessTokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);
    }
  }

  Future<void> clearAll() async {
    if (kIsWeb) {
      final prefs = await _getPrefs();
      await prefs.clear();
    } else {
      await _secureStorage.deleteAll();
    }
  }
}