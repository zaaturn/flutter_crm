class EmployeeModel {
  final String? name;               // API does not return this, derive from username
  final String employeeId;
  final String username;
  final String? profilePhoto;

  EmployeeModel({
    required this.employeeId,
    required this.username,
    this.name,
    this.profilePhoto,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    final username = json["username"]?.toString() ?? "";


    final derivedName = username.contains("@")
        ? username.split("@").first
        : username;

    return EmployeeModel(
      employeeId: json["employee_id"]?.toString() ?? "",
      username: username,
      profilePhoto: json["profile_photo"]?.toString(),
      name: derivedName,
    );
  }
}

