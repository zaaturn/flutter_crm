import 'package:my_app/client tracker/features/clients/models/client_model.dart';

abstract class ClientState {}

class ClientInitial  extends ClientState {}
class ClientLoading  extends ClientState {}

class ClientListLoaded extends ClientState {
  final List<ClientModel> clients;
  ClientListLoaded(this.clients);
}

class ClientDetailLoaded extends ClientState {
  final ClientModel client;
  final List<ClientServiceModel> services;
  final List<ClientCredentialModel> credentials;

  ClientDetailLoaded({
    required this.client,
    required this.services,
    required this.credentials,
  });
}

class ClientSaved extends ClientState {
  final ClientModel client;
  ClientSaved(this.client);
}

class ClientError extends ClientState {
  final String message;
  ClientError(this.message);
}