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
      // Refresh details to show new credential
      add(LoadClientDetailEvent(e.clientId));
    } catch (err) {
      emit(ClientError(err.toString()));
    }
  }

  // --- UPDATED HANDLER: FORCES REFRESH OF CLIENT & SERVICES ---
  Future<void> _onUpdateClient(
      UpdateClientEvent e,
      Emitter<ClientState> emit,
      ) async {
    // 1. Emit loading to clear old UI state
    emit(ClientLoading());

    try {
      // 2. Perform the PATCH update (The 200 OK part)
      await _repo.updateClient(e.clientId, e.clientData);

      // 3. Handle Services logic from the text field string
      if (e.clientData.containsKey('services')) {
        final String servicesString = e.clientData['services'] ?? '';
        final List<String> serviceNames = servicesString
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();

        if (serviceNames.isNotEmpty) {
          final List<Map<String, dynamic>> servicesToSave = serviceNames.map((name) => {
            'client': e.clientId,
            'service_name': name,
          }).toList();

          // Create the new services in the DB
          await _repo.createServices(servicesToSave);
        }
      }

      // 4. Wait slightly to ensure the Backend DB has finished writing
      await Future.delayed(const Duration(milliseconds: 300));

      // 5. MANUALLY RE-FETCH everything from the database
      final updatedClient = await _repo.getClientById(e.clientId);
      final updatedServices = await _repo.getServices(e.clientId);
      final updatedCredentials = await _repo.getCredentials(e.clientId);

      // 6. Emit the Loaded state with the FRESH data (SEO + WEB APP)
      emit(ClientDetailLoaded(
        client: updatedClient,
        services: updatedServices,
        credentials: updatedCredentials,
      ));

    } catch (err) {
      emit(ClientError(err.toString()));
    }
  }
}