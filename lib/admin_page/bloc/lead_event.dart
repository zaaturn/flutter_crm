
import '../model/lead_model.dart';

abstract class LeadEvent {}

class CreateLeadEvent extends LeadEvent {
  final Lead lead;
  CreateLeadEvent(this.lead);
}
