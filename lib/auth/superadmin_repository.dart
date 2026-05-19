import 'package:my_app/services/api_client.dart';

/// Superadmin user management APIs (only when `is_superuser`).
class SuperadminRepository {
  final ApiClient _api = ApiClient();

  String get _base => '${_api.baseAccounts}/superadmin/users';

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final qp = <String, dynamic>{
      if (query.trim().isNotEmpty) 'search': query.trim(),
    };
    try {
      final map = await _api.get(_base, queryParameters: qp);
      final results = map['results'];
      if (results is List) {
        return results
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    } catch (_) {}
    final list = await _api.getList(_base, queryParameters: qp);
    return list
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<Map<String, dynamic>> getUserAccess(int id) async {
    return await _api.get('$_base/$id/access/');
  }

  Future<void> patchUserAccess(
    int id, {
    String? role,
    Map<String, bool>? modules,
  }) async {
    final body = <String, dynamic>{
      if (role != null) 'role': role,
      if (modules != null) 'admin_modules': modules,
    };
    await _api.patch('$_base/$id/access/', body: body);
  }
}
