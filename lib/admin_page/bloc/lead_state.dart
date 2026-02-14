import '../model/lead_model.dart';

abstract class LeadState {}

class LeadInitial extends LeadState {}

/// When all leads are fetched successfully
class LeadLoaded extends LeadState {
  final List<Lead> leads;
  LeadLoaded(this.leads);
}

/// When a lead is being created
class LeadCreating extends LeadState {}

/// When a lead is created successfully
class LeadCreateSuccess extends LeadState {}

/// When lead creation fails
class LeadCreateFailure extends LeadState {
  final String message;
  LeadCreateFailure(this.message);
}

