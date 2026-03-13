// ══════════════════════════════════════════════
// CLIENT MODEL
// ══════════════════════════════════════════════
class ClientModel {
  final int id;
  final String name;
  final String? about, address, phone, email, createdAt;
  final int servicesCount;

  ClientModel({
    required this.id,
    required this.name,
    this.about, this.address, this.phone, this.email, this.createdAt,
    this.servicesCount = 0,
  });

  factory ClientModel.fromJson(Map<String, dynamic> j) => ClientModel(
    id:            j['id'],
    name:          j['name'] ?? '',
    about:         j['about'],
    address:       j['address'],
    phone:         j['phone'],
    email:         j['email'],
    servicesCount: j['services_count'] ?? 0,
    createdAt:     j['created_at'],
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    if (about   != null) 'about':   about,
    if (address != null) 'address': address,
    if (phone   != null) 'phone':   phone,
    if (email   != null) 'email':   email,
  };
}

// ══════════════════════════════════════════════
// SERVICE MODEL
// ══════════════════════════════════════════════
class ClientServiceModel {
  final int? id;
  final int clientId;
  final String serviceName;

  ClientServiceModel({this.id, required this.clientId, required this.serviceName});

  factory ClientServiceModel.fromJson(Map<String, dynamic> j) => ClientServiceModel(
    id:          j['id'],
    clientId:    j['client'],
    serviceName: j['service_name'] ?? '',
  );

  Map<String, dynamic> toJson() => {'client': clientId, 'service_name': serviceName};
}

// ══════════════════════════════════════════════
// CREDENTIAL MODEL
// ══════════════════════════════════════════════
class ClientCredentialModel {
  final int? id;
  final int clientId;
  final String platform;
  final String? platformDisplay, username, password;

  ClientCredentialModel({
    this.id, required this.clientId, required this.platform,
    this.platformDisplay, this.username, this.password,
  });

  factory ClientCredentialModel.fromJson(Map<String, dynamic> j) => ClientCredentialModel(
    id:              j['id'],
    clientId:        j['client'],
    platform:        j['platform'] ?? '',
    platformDisplay: j['platform_display'],
    username:        j['username'],
    password:        j['password'],
  );

  Map<String, dynamic> toJson() => {
    'client':   clientId,
    'platform': platform,
    if (username != null) 'username': username,
    if (password != null) 'password': password,
  };
}