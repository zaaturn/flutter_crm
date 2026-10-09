import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:my_app/services/api_client.dart';

class ChoiceOption {
  const ChoiceOption(this.value, this.label);
  final String value;
  final String label;
}

class NamedOption {
  const NamedOption(this.id, this.name);
  final int id;
  final String name;
}

class UserFormOptions {
  const UserFormOptions({
    required this.roles,
    required this.genders,
    required this.workLocations,
    required this.departments,
    required this.designations,
  });

  final List<ChoiceOption> roles;
  final List<ChoiceOption> genders;
  final List<ChoiceOption> workLocations;
  final List<NamedOption> departments;
  final List<NamedOption> designations;

  factory UserFormOptions.fromJson(Map<String, dynamic> json) {
    List<ChoiceOption> choices(String key) => (json[key] is List ? json[key] as List : const [])
        .whereType<Map>()
        .map((e) => ChoiceOption('${e['value']}', '${e['label']}'))
        .toList();
    List<NamedOption> named(String key) => (json[key] is List ? json[key] as List : const [])
        .whereType<Map>()
        .map((e) => NamedOption((e['id'] as num).toInt(), '${e['name']}'))
        .toList();
    return UserFormOptions(
      roles: choices('roles'),
      genders: choices('genders'),
      workLocations: choices('work_locations'),
      departments: named('departments'),
      designations: named('designations'),
    );
  }
}

/// A user as the superadmin sees and edits them.
class ManagedUser {
  const ManagedUser(this.raw);

  final Map<String, dynamic> raw;

  int get id => (raw['id'] as num).toInt();
  String get username => (raw['username'] ?? '').toString();
  String get firstName => (raw['first_name'] ?? '').toString();
  String get lastName => (raw['last_name'] ?? '').toString();
  String get fullName {
    final name = (raw['full_name'] ?? '').toString().trim();
    return name.isEmpty ? username : name;
  }

  String get email => (raw['email'] ?? '').toString();
  String get phone => (raw['phone_number'] ?? '').toString();
  String get employeeId => (raw['employee_id'] ?? '').toString();
  String get role => (raw['role'] ?? 'employee').toString();
  bool get isActive => raw['is_active'] != false;
  String get gender => (raw['gender'] ?? '').toString();
  String get address => (raw['address'] ?? '').toString();
  String get workLocation => (raw['work_location'] ?? 'WFO').toString();
  int? get departmentId => (raw['department'] as num?)?.toInt();
  int? get designationId => (raw['designation'] as num?)?.toInt();
  String get departmentLabel => (raw['department_label'] ?? '').toString();
  String get designationLabel => (raw['designation_label'] ?? '').toString();
  String? get photoUrl => raw['profile_photo_url']?.toString();
  DateTime? get dateOfBirth => _date(raw['date_of_birth']);
  DateTime? get dateOfJoining => _date(raw['date_of_joining']);

  static DateTime? _date(dynamic v) =>
      v == null || '$v'.isEmpty ? null : DateTime.tryParse('$v');

  String get roleLabel {
    switch (role) {
      case 'superadmin':
        return 'Super admin';
      case 'admin':
        return 'Admin';
      case 'client':
        return 'Client';
      default:
        return 'Employee';
    }
  }
}

class UserPage {
  const UserPage(this.users, this.count, this.hasMore);
  final List<ManagedUser> users;
  final int count;
  final bool hasMore;
}

/// Add / edit / deactivate users — what used to need Django admin.
class UserAdminRepository {
  final ApiClient _api = ApiClient();

  String get _base => '${_api.baseAccounts}/superadmin/manage';

  static String iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<UserFormOptions> options() async =>
      UserFormOptions.fromJson(await _api.get('$_base/options/'));

  Future<UserPage> list({String search = '', String status = 'active', int page = 1}) async {
    final data = await _api.get('$_base/users/', queryParameters: {
      if (search.trim().isNotEmpty) 'search': search.trim(),
      'status': status,
      'page': page,
    });
    final results = data['results'] is List ? data['results'] as List : const [];
    return UserPage(
      results
          .whereType<Map>()
          .map((e) => ManagedUser(Map<String, dynamic>.from(e)))
          .toList(),
      (data['count'] as num?)?.toInt() ?? results.length,
      data['next'] != null,
    );
  }

  Future<ManagedUser> get(int id) async =>
      ManagedUser(await _api.get('$_base/users/$id/'));

  /// [fields] are plain form values; a photo, when picked, goes up in the
  /// same multipart request.
  Future<ManagedUser> save({
    int? id,
    required Map<String, dynamic> fields,
    Uint8List? photo,
    String? photoName,
  }) async {
    final body = <String, dynamic>{
      for (final e in fields.entries)
        if (e.value != null) e.key: e.value is bool ? '${e.value}' : e.value,
    };
    if (photo != null) {
      body['profile_photo'] = MultipartFile.fromBytes(photo, filename: photoName ?? 'photo.jpg');
    }
    final form = FormData.fromMap(body);
    final data = id == null
        ? await _api.post('$_base/users/', body: form)
        : await _api.patch('$_base/users/$id/', body: form);
    return ManagedUser(data);
  }

  Future<String> resetPassword(int id, String password) async {
    final data = await _api.post('$_base/users/$id/password/', body: {'password': password});
    return (data['detail'] ?? 'Password updated.').toString();
  }

  Future<ManagedUser> setActive(int id, bool active) async {
    final data = await _api.post('$_base/users/$id/${active ? 'activate' : 'deactivate'}/');
    return ManagedUser(data);
  }
}
