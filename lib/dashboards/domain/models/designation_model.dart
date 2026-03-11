class DesignationModel {
  final int id;
  final String name;

  DesignationModel({
    required this.id,
    required this.name,
  });

  factory DesignationModel.fromJson(Map<String, dynamic> json) {
    return DesignationModel(
      id: json["id"],
      name: json["name"],
    );
  }
}