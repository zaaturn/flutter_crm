class UserEntity {
  final int id;
  final String username;
  final String email;
  final String? employeeId;
  final String? phoneNumber;
  final String? firstName;
  final String? lastName;

  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    this.employeeId,
    this.phoneNumber,
    this.firstName,
    this.lastName,
  });
}