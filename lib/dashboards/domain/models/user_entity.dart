class UserEntity {
  final int id;
  final String username;
  final String email;
  final String? employeeId;
  final String? phoneNumber;
  final String? firstName;
  final String? lastName;

  /// Some serializers expose a single `name` instead of first/last.
  final String? fullName;

  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    this.employeeId,
    this.phoneNumber,
    this.firstName,
    this.lastName,
    this.fullName,
  });

  /// Label for pickers (never empty if id is valid).
  String get displayLabel {
    final fromParts = [firstName, lastName]
        .whereType<String>()
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .join(' ')
        .trim();
    if (fromParts.isNotEmpty) return fromParts;
    final n = fullName?.trim();
    if (n != null && n.isNotEmpty) return n;
    final u = username.trim();
    if (u.isNotEmpty) return u;
    final e = email.trim();
    if (e.isNotEmpty) return e;
    return 'User #$id';
  }
}