import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/lead_model.dart';
import '../repository/lead_repository.dart';
import 'lead_event.dart';
import 'lead_state.dart';

class LeadBloc extends Bloc<LeadEvent, LeadState> {
  final LeadRepository repository;

  LeadBloc(this.repository) : super(LeadInitial()) {

    on<CreateLeadEvent>(_createLead);
  }

  Future<void> _createLead(
      CreateLeadEvent event, Emitter<LeadState> emit) async {
    try {
      emit(LeadCreating()); // loading

      // API call
      await repository.createLead(event.lead);

      emit(LeadCreateSuccess());
    } catch (e) {
      emit(LeadCreateFailure("Failed to create lead: $e"));
    }
  }
}

