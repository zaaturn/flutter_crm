class Approver {
  final int id;
  final String name;

  Approver({
    required this.id,
    required this.name,
  });

  factory Approver.fromJson(Map<String, dynamic> json) {
    return Approver(
      id: json['id'],
      name: json['name'],
    );
  }
}
