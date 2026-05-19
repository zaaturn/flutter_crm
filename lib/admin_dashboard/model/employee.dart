import 'package:flutter/material.dart';

enum LiveStatus { working, breakTime, loggedOut }

class Employee {
  final int id;
  final String name;
  final String firstName;
  final String lastName;
  final String email;
  final String employeeId;
  final String? username;
  final String? phoneNumber;
  final String? designation;
  final String? department;
  final String? workLocation;
  final String? address;
  final String? dateOfBirth;
  final String? dateOfJoining;
  final bool isActive;
  final String? profilePhoto;

  final LiveStatus liveStatus;
  final String checkIn;
  final String checkOut;

  const Employee({
    required this.id,
    required this.name,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.employeeId,
    this.username,
    this.phoneNumber,
    this.designation,
    this.department,
    this.workLocation,
    this.address,
    this.dateOfBirth,
    this.dateOfJoining,
    this.isActive = true,
    this.profilePhoto,
    this.liveStatus = LiveStatus.loggedOut,
    this.checkIn = '-',
    this.checkOut = '-',
  });

  String get fullName => '$firstName $lastName'.trim();


  /// Shown on profile; uses [username] as returned by API (no trim — preserves intentional spacing).
  String get profileUsernameHandle {
    final raw = _usernameAsStored(username);
    if (raw != null) return raw;
    final n = name.trim();
    if (n.isNotEmpty) {
      if (n.contains('@')) return n;
      return n.startsWith('@') ? n : '@$n';
    }
    return '—';
  }

  /// `null` / empty only; does **not** trim (backend `username` must round-trip as sent).
  static String? _usernameAsStored(String? s) {
    if (s == null || s.isEmpty) return null;
    return s;
  }

  static String? _usernameFromJsonValue(dynamic v) {
    if (v == null) return null;
    if (v is String) return v.isEmpty ? null : v;
    final s = v.toString();
    return s.isEmpty ? null : s;
  }

  /// Reads login fields without trimming (EmployeeListSerializer `username` etc.).
  static String? _readUsernameKeys(Map<String, dynamic> m) {
    for (final key in const ['username', 'user_name', 'userName']) {
      final hit = _usernameFromJsonValue(m[key]);
      if (hit != null) return hit;
    }
    for (final key in const [
      'org_username',
      'organization_username',
      'crm_username',
      'employee_login',
      'company_username',
      'login_username',
      'dax_username',
    ]) {
      final s = _optStr(m[key]);
      if (s != null) return s;
    }
    return null;
  }

  static String? _optStr(dynamic v) {
    final s = v?.toString().trim();
    return (s == null || s.isEmpty) ? null : s;
  }

  /// After nested `user` merge, restores list root `username` if merge left it missing/null
  /// (nested payload often omits or nulls `username` while `EmployeeListSerializer` sets it on root).
  static Map<String, dynamic> _flattenEmployeesListItem(
      Map<String, dynamic> json) {
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
    final rootUsername = json['username'];
    final rootUserName = json['user_name'];
    merged
      ..remove('name')
      ..remove('full_name');
    u.forEach((k, v) => merged[k] = v);
    if (json['employee_id'] != null) {
      merged['employee_id'] = json['employee_id'];
    }
    if (_usernameFromJsonValue(merged['username']) == null &&
        _usernameFromJsonValue(rootUsername) != null) {
      merged['username'] = rootUsername;
    }
    if (_usernameFromJsonValue(merged['user_name']) == null &&
        _usernameFromJsonValue(rootUserName) != null) {
      merged['user_name'] = rootUserName;
    }
    return merged;
  }

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty ? lastName[0] : '';
    return '$f$l'.toUpperCase();
  }

  bool get isOnline => liveStatus != LiveStatus.loggedOut;

  String get statusText {
    switch (liveStatus) {
      case LiveStatus.working:
        return 'Working';
      case LiveStatus.breakTime:
        return 'On Break';
      case LiveStatus.loggedOut:
        return 'Logged Out';
    }
  }

  Color get statusColor {
    switch (liveStatus) {
      case LiveStatus.working:
        return Colors.green;
      case LiveStatus.breakTime:
        return Colors.orange;
      case LiveStatus.loggedOut:
        return Colors.redAccent;
    }
  }

  IconData get statusIcon {
    switch (liveStatus) {
      case LiveStatus.working:
        return Icons.circle;
      case LiveStatus.breakTime:
        return Icons.pause_circle;
      case LiveStatus.loggedOut:
        return Icons.cancel;
    }
  }

  factory Employee.fromJson(Map<String, dynamic> json) {
    final original = Map<String, dynamic>.from(json);
    final j = _flattenEmployeesListItem(original);

    bool truthy(dynamic v) {
      if (v == null) return false;
      if (v is bool) return v;
      if (v is num) return v != 0;
      final s = v.toString().trim().toLowerCase();
      return s == 'true' || s == '1' || s == 'yes' || s == 'y';
    }

    final onBreak = truthy(j['on_break']) ||
        truthy(j['is_on_break']) ||
        truthy(j['is_break']) ||
        truthy(j['break']) ||
        truthy(j['break_time']) ||
        truthy(j['onBreak']);
    String? optStr(dynamic v) {
      final s = v?.toString().trim();
      return (s == null || s.isEmpty) ? null : s;
    }

    final resolvedLogin =
        _readUsernameKeys(j) ?? _readUsernameKeys(original) ?? optStr(j['userName']);

    return Employee(
      id: j['id'] ?? 0,
      name: j['name']?.toString() ?? '',
      firstName: j['first_name']?.toString() ?? '',
      lastName: j['last_name']?.toString() ?? '',
      email: j['email']?.toString() ?? '',
      employeeId: j['employee_id']?.toString() ?? '',
      username: resolvedLogin,
      phoneNumber: j['phone_number']?.toString(),
      designation: j['designation']?.toString(),
      department: j['department']?.toString(),
      workLocation: j['work_location']?.toString(),
      address: j['address']?.toString(),
      dateOfBirth: j['date_of_birth']?.toString(),
      dateOfJoining: j['date_of_joining']?.toString(),
      isActive: j['is_active'] ?? true,
      profilePhoto: j['profile_photo']?.toString(),
      liveStatus:
          onBreak ? LiveStatus.breakTime : _parseLiveStatus(j['status']),
      checkIn: j['check_in']?.toString() ?? '-',
      checkOut: j['check_out']?.toString() ?? '-',

    );
  }

  Employee copyWith({
    LiveStatus? liveStatus,
    String? checkIn,
    String? checkOut,
    bool? isActive,
    String? profilePhoto,
    String? username,
  }) {
    return Employee(
      id: id,
      name: name,
      firstName: firstName,
      lastName: lastName,
      email: email,
      employeeId: employeeId,
      username: username ?? this.username,
      phoneNumber: phoneNumber,
      designation: designation,
      department: department,
      workLocation: workLocation,
      address: address,
      dateOfBirth: dateOfBirth,
      dateOfJoining: dateOfJoining,
      isActive: isActive ?? this.isActive,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      liveStatus: liveStatus ?? this.liveStatus,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
    );
  }

  static LiveStatus _parseLiveStatus(dynamic s) {
    final v = s?.toString().trim().toLowerCase();
    switch (v) {
      case 'working':
      case 'work':
      case 'checked_in':
      case 'checkin':
      case 'online':
        return LiveStatus.working;
      case 'break':
      case 'on_break':
      case 'break_time':
      case 'paused':
        return LiveStatus.breakTime;
      case 'loggedout':
      case 'logged_out':
      case 'logout':
      case 'checked_out':
      case 'checkout':
      case 'offline':
        return LiveStatus.loggedOut;
      default:
        return LiveStatus.loggedOut;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Employee && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Employee(id: $id, name: $fullName, status: $statusText)';
}
