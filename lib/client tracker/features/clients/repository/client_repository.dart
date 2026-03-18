import 'package:my_app/client tracker/core/network/api_services.dart';
import 'package:my_app/client tracker/core/constants/app_constant.dart';
import 'package:my_app/client tracker/features/clients/models/client_model.dart';

class ClientRepository {
  final _api = ApiClient();

  Future<List<ClientModel>> getClients() async {
    final data = await _api.get(AppConstants.clients);
    return (data as List).map((e) => ClientModel.fromJson(e)).toList();
  }

  Future<ClientModel> getClientById(int id) async {
    final data = await _api.get(AppConstants.clientById(id));
    return ClientModel.fromJson(data);
  }

  Future<ClientModel> createClient(Map<String, dynamic> body) async {
    final data = await _api.post(AppConstants.clients, body);
    return ClientModel.fromJson(data);
  }

  Future<List<ClientServiceModel>> getServices(int clientId) async {
    final data = await _api.get(AppConstants.servicesByClient(clientId));
    return (data as List).map((e) => ClientServiceModel.fromJson(e)).toList();
  }

  Future<void> createServices(List<Map<String, dynamic>> body) async {
    if (body.isEmpty) return;
    await _api.postList(AppConstants.services, body);
  }

  Future<List<ClientCredentialModel>> getCredentials(int clientId) async {
    final data = await _api.get(AppConstants.credentialsByClient(clientId));
    return (data as List).map((e) => ClientCredentialModel.fromJson(e)).toList();
  }

  Future<void> createCredentials(List<Map<String, dynamic>> body) async {
    if (body.isEmpty) return;
    await _api.postList(AppConstants.credentials, body);
  }

  Future<void> updateClient(int clientId, Map<String, dynamic> data) async {
    await _api.patch(AppConstants.clientById(clientId), data);
  }


  Future<void> deleteClient(int clientId) async {

    await _api.delete(AppConstants.clientById(clientId));
  }
}