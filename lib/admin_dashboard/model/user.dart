import 'package:my_app/auth/auth_session.dart';

class User {
  final int id;
  final String username;
  final String? firstName;
  final String? lastName;
  final String? role;
  final bool isSuperuser;

  User({
    required this.id,
    required this.username,
    this.firstName,
    this.lastName,
    this.role,
    this.isSuperuser = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['id'] as int?) ?? int.tryParse('${json['id']}') ?? 0,
      username: json['username']?.toString() ?? '',
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      role: json['role']?.toString(),
      isSuperuser: AuthSession.parseBool(json['is_superuser']),
    );
  }

  String get displayName =>
      "${firstName ?? ''} ${lastName ?? ''}".trim().isNotEmpty
          ? "${firstName ?? ''} ${lastName ?? ''}".trim()
          : username;

  /// List / picker label with role when useful (avatar initials still use [displayName]).
  String get assignmentLabel {
    final base = displayName;
    if (isSuperuser) return '$base · Superuser';
    final r = role?.trim();
    if (r != null && r.isNotEmpty && r.toLowerCase() != 'employee') {
      return '$base · $r';
    }
    return base;
  }
}
