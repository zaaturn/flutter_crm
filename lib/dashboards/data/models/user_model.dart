import '../../domain/models/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    super.employeeId,
    super.phoneNumber,
    super.firstName,
    super.lastName,
    super.fullName,
  });

  /// `employeeslist/` often nests the login profile under `user` while the root `name` field
  /// may duplicate department/project labels. Prefer nested account fields and user id for targeting.
  static Map<String, dynamic> _flattenEmployeeJson(Map<String, dynamic> json) {
    final nested = json['user'];
    if (nested is! Map || nested.isEmpty) {
      return Map<String, dynamic>.from(json);
    }
    final u = Map<String, dynamic>.from(nested);
    if (u['id'] == null &&
        u['username'] == null &&
        u['first_name'] == null &&
        u['email'] == null) {
      return Map<String, dynamic>.from(json);
    }
    final merged = Map<String, dynamic>.from(json);
    merged
      ..remove('name')
      ..remove('full_name');
    u.forEach((k, v) => merged[k] = v);
    if (json['employee_id'] != null) {
      merged['employee_id'] = json['employee_id'];
    }
    return merged;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final m = _flattenEmployeeJson(Map<String, dynamic>.from(json));
    final idVal = m['id'];
    final id = idVal is int ? idVal : int.tryParse('$idVal') ?? 0;
    return UserModel(
      id: id,
      username: (m['username'] as String?)?.trim() ?? '',
      email: (m['email'] as String?)?.trim() ?? '',
      employeeId: m['employee_id']?.toString(),
      phoneNumber: m['phone_number']?.toString(),
      firstName: m['first_name'] as String?,
      lastName: m['last_name'] as String?,
      fullName: m['name'] as String? ?? m['full_name'] as String?,
    );
  }
}