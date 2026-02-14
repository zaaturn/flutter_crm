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
      id: json['id'],
      username: json['username'],
      firstName: json['first_name'],
      lastName: json['last_name'],
    );
  }

  String get displayName =>
      "${firstName ?? ''} ${lastName ?? ''}".trim().isNotEmpty
          ? "${firstName ?? ''} ${lastName ?? ''}".trim()
          : username;
}
