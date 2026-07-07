/// Full employee profile from `GET/PATCH /api/employee/crm/profile/`.
class EmployeeProfile {
  final String employeeId;
  final String username;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? fullName;
  final String? phoneNumber;
  final String? address;
  final String? role;
  final String? roleDisplay;
  final int? departmentId;
  final String? department;
  final int? designationId;
  final String? designation;
  final String? workLocation;
  final String? workLocationDisplay;
  final String? dateOfBirth;
  final String? dateOfJoining;
  final String? gender;
  final String? genderDisplay;
  final String? profilePhoto;
  final int? userId;

  const EmployeeProfile({
    required this.employeeId,
    required this.username,
    this.email,
    this.firstName,
    this.lastName,
    this.fullName,
    this.phoneNumber,
    this.address,
    this.role,
    this.roleDisplay,
    this.departmentId,
    this.department,
    this.designationId,
    this.designation,
    this.workLocation,
    this.workLocationDisplay,
    this.dateOfBirth,
    this.dateOfJoining,
    this.gender,
    this.genderDisplay,
    this.profilePhoto,
    this.userId,
  });

  bool get hasGender => gender != null && gender!.trim().isNotEmpty;

  bool get hasPhoto =>
      profilePhoto != null && profilePhoto!.trim().isNotEmpty;

  String get displayName {
    final full = fullName?.trim();
    if (full != null && full.isNotEmpty) return full;
    final parts = [firstName, lastName]
        .whereType<String>()
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .join(' ')
        .trim();
    if (parts.isNotEmpty) return parts;
    final u = username.trim();
    if (u.isEmpty) return 'User';
    if (u.contains('@')) return u.split('@').first;
    return u;
  }

  String get avatarInitials {
    final d = displayName.trim();
    if (d.isEmpty) return 'U';
    final words =
        d.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (words.length >= 2) {
      return (words[0][0] + words[1][0]).toUpperCase();
    }
    if (d.length >= 2) return d.substring(0, 2).toUpperCase();
    return d[0].toUpperCase();
  }

  static Map<String, dynamic> normalizeProfileJson(Map<String, dynamic> json) {
    final m = Map<String, dynamic>.from(json);
    final nested = m['user'];
    if (nested is! Map || nested.isEmpty) return m;
    final u = Map<String, dynamic>.from(nested);
    u.forEach((k, v) {
      final cur = m[k];
      final empty = cur == null || (cur is String && cur.trim().isEmpty);
      if (empty && v != null && v.toString().trim().isNotEmpty) {
        m[k] = v;
      }
    });
    return m;
  }

  factory EmployeeProfile.fromJson(Map<String, dynamic> json) {
    final m = normalizeProfileJson(Map<String, dynamic>.from(json));
    return EmployeeProfile(
      employeeId: m['employee_id']?.toString() ?? '',
      username: m['username']?.toString() ?? '',
      email: m['email']?.toString(),
      firstName: m['first_name']?.toString(),
      lastName: m['last_name']?.toString(),
      fullName: m['full_name']?.toString(),
      phoneNumber: m['phone_number']?.toString(),
      address: m['address']?.toString(),
      role: m['role']?.toString(),
      roleDisplay: m['role_display']?.toString(),
      departmentId: _nullableInt(m['department_id']),
      department: m['department']?.toString(),
      designationId: _nullableInt(m['designation_id']),
      designation: m['designation']?.toString(),
      workLocation: m['work_location']?.toString(),
      workLocationDisplay: m['work_location_display']?.toString(),
      dateOfBirth: m['date_of_birth']?.toString(),
      dateOfJoining: m['date_of_joining']?.toString(),
      gender: m['gender']?.toString(),
      genderDisplay: m['gender_display']?.toString(),
      profilePhoto: m['profile_photo']?.toString(),
      userId: _nullableInt(m['user_id'] ?? m['id']),
    );
  }

  static int? _nullableInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  EmployeeProfile copyWith({
    String? employeeId,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? fullName,
    String? phoneNumber,
    String? address,
    String? role,
    String? roleDisplay,
    int? departmentId,
    String? department,
    int? designationId,
    String? designation,
    String? workLocation,
    String? workLocationDisplay,
    String? dateOfBirth,
    String? dateOfJoining,
    String? gender,
    String? genderDisplay,
    String? profilePhoto,
    int? userId,
  }) {
    return EmployeeProfile(
      employeeId: employeeId ?? this.employeeId,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      role: role ?? this.role,
      roleDisplay: roleDisplay ?? this.roleDisplay,
      departmentId: departmentId ?? this.departmentId,
      department: department ?? this.department,
      designationId: designationId ?? this.designationId,
      designation: designation ?? this.designation,
      workLocation: workLocation ?? this.workLocation,
      workLocationDisplay: workLocationDisplay ?? this.workLocationDisplay,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      dateOfJoining: dateOfJoining ?? this.dateOfJoining,
      gender: gender ?? this.gender,
      genderDisplay: genderDisplay ?? this.genderDisplay,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      userId: userId ?? this.userId,
    );
  }
}
