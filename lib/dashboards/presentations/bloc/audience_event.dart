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

/// Select/deselect all currently visible items for the active tab.
///
/// This respects the current search/filter, so "Select all" only applies to the
/// loaded `items` list, not the entire database.
class AudienceSelectAllToggled extends AudienceEvent {
  final bool select;
  AudienceSelectAllToggled({required this.select});
}

/// Clear targeting selections. If [onlyTab] is set, only that dimension is cleared.
class AudienceSelectionCleared extends AudienceEvent {
  final AudienceTab? onlyTab;
  AudienceSelectionCleared({this.onlyTab});
}

/// Internal — fired by debounce timer; not dispatched by UI.
class AudienceFetchDebounced extends AudienceEvent {
  final String query;
  AudienceFetchDebounced(this.query);
}