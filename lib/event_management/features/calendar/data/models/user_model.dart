class UserMini {
  final int id;
  final String name;

  UserMini({required this.id, required this.name});

  factory UserMini.fromJson(Map<String, dynamic> j) =>
      UserMini(id: j['id'], name: j['name']);
}
