class ClientModel {
  final String id;
  final String name;
  final String? gstin;
  final Map<String, dynamic> address;
  final String state;

  ClientModel({
    required this.id,
    required this.name,
    this.gstin,
    required this.address,
    required this.state,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json["id"],
      name: json["name"],
      gstin: json["gstin"],
      address: json["address"] ?? {},
      state: json["state"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "gstin": gstin,
      "address": address,
      "state": state,
    };
  }
}
