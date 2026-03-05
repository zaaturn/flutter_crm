import 'package:my_app/dashboards/widgets/audience_tab.dart';

abstract class AudienceEvent {}

/// Switch between Department / Designation / Specific Users tabs.
class AudienceTabChanged extends AudienceEvent {
  final AudienceTab tab;
  AudienceTabChanged(this.tab);
}

/// User typed in the search field — debounced before API call.
class AudienceSearchChanged extends AudienceEvent {
  final String query;
  AudienceSearchChanged(this.query);
}

/// User ticked or unticked a list item.
class AudienceItemToggled extends AudienceEvent {
  final String item;
  AudienceItemToggled(this.item);
}

/// "Clear All" button pressed.
class AudienceSelectionCleared extends AudienceEvent {}

/// Internal — fired by debounce timer; not dispatched by UI.
class AudienceFetchDebounced extends AudienceEvent {
  final String query;
  AudienceFetchDebounced(this.query);
}