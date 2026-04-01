class User {
  final int id;
  final String username;
  final String? firstName;
  final String? lastName;

  User({
    required this.id,
    required this.username,
    this.firstName,
    this.lastName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['id'] as int?) ?? int.tryParse('${json['id']}') ?? 0,
      username: json['username']?.toString() ?? '',
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
    );
  }

  String get displayName =>
      "${firstName ?? ''} ${lastName ?? ''}".trim().isNotEmpty
          ? "${firstName ?? ''} ${lastName ?? ''}".trim()
          : username;
}
