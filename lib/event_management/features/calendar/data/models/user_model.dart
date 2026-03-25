class UserMini {
  final int id;
  final String name;

  UserMini({required this.id, required this.name});

  factory UserMini.fromJson(Map<String, dynamic> j) {
    final first = j['first_name'] ?? '';
    final last = j['last_name'] ?? '';

    return UserMini(
      id: j['id'],
      name: (first + ' ' + last).trim(),
    );
  }
}