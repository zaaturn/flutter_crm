import 'package:flutter_bloc/flutter_bloc.dart';
import 'client_event.dart';
import 'client_state.dart';
import '../repository/client_repository.dart';

class ClientBloc extends Bloc<ClientEvent, ClientState> {
  final ClientRepository _repo;

  ClientBloc(this._repo) : super(ClientInitial()) {
    on<LoadClientsEvent>(_onLoadClients);
    on<LoadClientDetailEvent>(_onLoadDetail);
    on<SaveClientEvent>(_onSave);
    on<AddClientCredentialsEvent>(_onAddCredentials);
    on<UpdateClientEvent>(_onUpdateClient);
    // REGISTER THE NEW DELETE EVENT
    on<DeleteClientEvent>(_onDeleteClient);
  }

  Future<void> _onLoadClients(
      LoadClientsEvent e,
      Emitter<ClientState> emit,
      ) async {
    emit(ClientLoading());
    try {
      final clients = await _repo.getClients();
      emit(ClientListLoaded(clients));
    } catch (err) {
      emit(ClientError(err.toString()));
    }
  }

  Future<void> _onLoadDetail(
      LoadClientDetailEvent e,
      Emitter<ClientState> emit,
      ) async {
    emit(ClientLoading());
    try {
      final client = await _repo.getClientById(e.clientId);
      final services = await _repo.getServices(e.clientId);
      final credentials = await _repo.getCredentials(e.clientId);

      emit(
        ClientDetailLoaded(
          client: client,
          services: services,
          credentials: credentials,
        ),
      );
    } catch (err) {
      emit(ClientError(err.toString()));
    }
  }

  Future<void> _onSave(
      SaveClientEvent e,
      Emitter<ClientState> emit,
      ) async {
    emit(ClientLoading());
    try {
      final client = await _repo.createClient(e.clientData);

      await _repo.createServices(
        e.services
            .where((s) => s.trim().isNotEmpty)
            .map((s) => {
          'client': client.id,
          'service_name': s,
        })
            .toList(),
      );

      await _repo.createCredentials(
        e.credentials
            .where((c) => c['platform'] != null)
            .map((c) => {...c, 'client': client.id})
            .toList(),
      );

      emit(ClientSaved(client));
    } catch (err) {
      emit(ClientError(err.toString()));
    }
  }

  Future<void> _onAddCredentials(
      AddClientCredentialsEvent e,
      Emitter<ClientState> emit,
      ) async {
    try {
      await _repo.createCredentials(e.credentials);
      add(LoadClientDetailEvent(e.clientId));
    } catch (err) {
      emit(ClientError(err.toString()));
    }
  }

  Future<void> _onUpdateClient(
      UpdateClientEvent e,
      Emitter<ClientState> emit,
      ) async {
    emit(ClientLoading());
    try {
      await _repo.updateClient(e.clientId, e.clientData);

      if (e.clientData.containsKey('services')) {
        final String servicesString = e.clientData['services'] ?? '';
        final List<String> serviceNames = servicesString
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();

        if (serviceNames.isNotEmpty) {
          final List<Map<String, dynamic>> servicesToSave =
          serviceNames.map((name) => {
            'client': e.clientId,
            'service_name': name,
          }).toList();

          await _repo.createServices(servicesToSave);
        }
      }

      await Future.delayed(const Duration(milliseconds: 300));

      final updatedClient = await _repo.getClientById(e.clientId);
      final updatedServices = await _repo.getServices(e.clientId);
      final updatedCredentials = await _repo.getCredentials(e.clientId);

      emit(ClientDetailLoaded(
        client: updatedClient,
        services: updatedServices,
        credentials: updatedCredentials,
      ));
    } catch (err) {
      emit(ClientError(err.toString()));
    }
  }

  // --- NEW DELETE HANDLER ---
  Future<void> _onDeleteClient(
      DeleteClientEvent e,
      Emitter<ClientState> emit,
      ) async {
    try {
      // 1. Call the repository to delete from Backend
      await _repo.deleteClient(e.clientId);

      // 2. Refresh the list automatically so the UI updates
      add(LoadClientsEvent());
    } catch (err) {
      emit(ClientError("Failed to delete client: ${err.toString()}"));
    }
  }
}