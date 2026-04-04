class EmployeeModel {
  final String? name;
  final String employeeId;
  final String username;
  final String? profilePhoto;
  final String? firstName;
  final String? lastName;

  EmployeeModel({
    required this.employeeId,
    required this.username,
    this.name,
    this.profilePhoto,
    this.firstName,
    this.lastName,
  });

  /// Prefer "First Last", then [name], then username without @domain.
  String get displayName {
    final parts = [firstName, lastName]
        .whereType<String>()
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .join(' ')
        .trim();
    if (parts.isNotEmpty) return parts;
    final n = name?.trim();
    if (n != null && n.isNotEmpty && n != '—') return n;
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

  /// Merges nested `user` into root so `first_name` / `last_name` resolve like [UserModel].
  static Map<String, dynamic> normalizeProfileJson(Map<String, dynamic> json) =>
      _mergeUserIntoRoot(json);

  static Map<String, dynamic> _mergeUserIntoRoot(Map<String, dynamic> json) {
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

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    final m = _mergeUserIntoRoot(Map<String, dynamic>.from(json));
    final username = m['username']?.toString() ?? '';

    final fn = m['first_name']?.toString().trim() ?? '';
    final ln = m['last_name']?.toString().trim() ?? '';
    final full = m['name']?.toString().trim() ?? m['full_name']?.toString().trim() ?? '';
    final fromParts = '$fn $ln'.trim();

    final resolvedName = fromParts.isNotEmpty
        ? fromParts
        : (full.isNotEmpty
            ? full
            : (username.contains('@')
                ? username.split('@').first
                : username));

    return EmployeeModel(
      employeeId: m['employee_id']?.toString() ?? '',
      username: username,
      profilePhoto: m['profile_photo']?.toString(),
      firstName: fn.isEmpty ? null : fn,
      lastName: ln.isEmpty ? null : ln,
      name: resolvedName.isEmpty ? null : resolvedName,
    );
  }
}
