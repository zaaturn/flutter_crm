import 'dart:convert';

/// Parsed login /me session for role-based shells and module gating.
class AuthSession {
  final String role;
  final bool isSuperuser;
  final Map<String, bool> adminModules;

  const AuthSession({
    required this.role,
    this.isSuperuser = false,
    this.adminModules = const {},
  });

  bool get isAdmin => role == 'admin';
  bool get isEmployee => role == 'employee';
  bool get isClient => role == 'client';

  /// Payroll admin UI: superuser, or admin with `admin_modules['payroll'] == true`.
  bool get canAccessPayrollAdmin =>
      isSuperuser || (isAdmin && adminModules['payroll'] == true);

  /// `null` or missing key → allowed (backward compatible).
  /// Superusers may access every module regardless of [adminModules].
  bool moduleAllowed(String? moduleKey) {
    if (isSuperuser) return true;
    if (moduleKey == null || moduleKey.isEmpty) return true;
    if (moduleKey == 'payroll') {
      return isSuperuser || (isAdmin && adminModules['payroll'] == true);
    }
    return adminModules[moduleKey] ?? true;
  }

  static Map<String, bool> parseAdminModules(dynamic raw) {
    if (raw is! Map) return {};
    return raw.map(
      (k, v) => MapEntry(k.toString(), v == true),
    );
  }

  static bool parseBool(dynamic v) {
    if (v == null) return false;
    if (v is bool) return v;
    if (v is num) return v != 0;
    final s = v.toString().trim().toLowerCase();
    return s == 'true' || s == '1' || s == 'yes';
  }

  /// Merge login + optional /me payload.
  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final role = (json['role']?.toString() ?? 'employee').toLowerCase();
    return AuthSession(
      role: role,
      isSuperuser: parseBool(json['is_superuser']),
      adminModules: parseAdminModules(json['admin_modules']),
    );
  }

  Map<String, dynamic> toJson() => {
        'role': role,
        'is_superuser': isSuperuser,
        'admin_modules': adminModules,
      };

  String toStorageJson() => jsonEncode(toJson());

  static AuthSession? fromStorageString(String? s) {
    if (s == null || s.isEmpty) return null;
    try {
      final m = jsonDecode(s) as Map<String, dynamic>;
      return AuthSession.fromJson(m);
    } catch (_) {
      return null;
    }
  }
}

/// Which shell an admin user is viewing.
enum ActiveDashboard { employee, admin }

extension ActiveDashboardStorage on ActiveDashboard {
  String get storageValue => name;

  static ActiveDashboard? fromString(String? s) {
    if (s == null || s.isEmpty) return null;
    for (final v in ActiveDashboard.values) {
      if (v.name == s) return v;
    }
    return null;
  }
}
