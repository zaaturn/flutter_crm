import 'package:my_app/dashboards/widgets/audience_tab.dart';

abstract class AudienceState {
  final AudienceTab activeTab;
  final String searchQuery;
  final Set<String> selected;

  const AudienceState({
    required this.activeTab,
    required this.searchQuery,
    required this.selected,
  });
}

class AudienceInitial extends AudienceState {
  const AudienceInitial()
      : super(
    activeTab: AudienceTab.byDepartment,
    searchQuery: '',
    selected: const {},
  );
}

class AudienceLoading extends AudienceState {
  const AudienceLoading({
    required super.activeTab,
    required super.searchQuery,
    required super.selected,
  });
}

class AudienceLoaded extends AudienceState {
  final List<String> items;

  const AudienceLoaded({
    required super.activeTab,
    required super.searchQuery,
    required super.selected,
    required this.items,
  });

  AudienceLoaded copyWith({
    AudienceTab? activeTab,
    String? searchQuery,
    Set<String>? selected,
    List<String>? items,
  }) {
    return AudienceLoaded(
      activeTab: activeTab ?? this.activeTab,
      searchQuery: searchQuery ?? this.searchQuery,
      selected: selected ?? this.selected,
      items: items ?? this.items,
    );
  }
}

class AudienceError extends AudienceState {
  final String message;

  const AudienceError({
    required super.activeTab,
    required super.searchQuery,
    required super.selected,
    required this.message,
  });
}