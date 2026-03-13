abstract class ClientEvent {}


class LoadClientsEvent extends ClientEvent {}


class LoadClientDetailEvent extends ClientEvent {
  final int clientId;

  LoadClientDetailEvent(this.clientId);
}


class SaveClientEvent extends ClientEvent {
  final Map<String, dynamic> clientData;
  final List<String> services;
  final List<Map<String, dynamic>> credentials;

  SaveClientEvent({
    required this.clientData,
    required this.services,
    required this.credentials,
  });
}

/// Update existing client information
class UpdateClientEvent extends ClientEvent {
  final int clientId;
  final Map<String, dynamic> clientData;

  UpdateClientEvent({
    required this.clientId,
    required this.clientData,
  });
}

/// Add new credentials to an existing client
class AddClientCredentialsEvent extends ClientEvent {
  final int clientId;
  final List<Map<String, dynamic>> credentials;

  AddClientCredentialsEvent({
    required this.clientId,
    required this.credentials,
  });
}