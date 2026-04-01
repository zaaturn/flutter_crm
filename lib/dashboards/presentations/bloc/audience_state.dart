import 'package:my_app/dashboards/widgets/audience_tab.dart';

abstract class AudienceState {
  final AudienceTab activeTab;
  final String searchQuery;
  final Set<String> selectedDepartments;
  final Set<String> selectedDesignations;
  final Set<String> selectedUsers;

  const AudienceState({
    required this.activeTab,
    required this.searchQuery,
    required this.selectedDepartments,
    required this.selectedDesignations,
    required this.selectedUsers,
  });

  Set<String> selectionFor(AudienceTab tab) {
    switch (tab) {
      case AudienceTab.byDepartment:
        return selectedDepartments;
      case AudienceTab.byDesignation:
        return selectedDesignations;
      case AudienceTab.specificUsers:
        return selectedUsers;
    }
  }

  int get totalSelectedCount =>
      selectedDepartments.length +
      selectedDesignations.length +
      selectedUsers.length;
}

class AudienceInitial extends AudienceState {
  const AudienceInitial()
      : super(
          activeTab: AudienceTab.byDepartment,
          searchQuery: '',
          selectedDepartments: const {},
          selectedDesignations: const {},
          selectedUsers: const {},
        );
}

class AudienceLoading extends AudienceState {
  const AudienceLoading({
    required super.activeTab,
    required super.searchQuery,
    required super.selectedDepartments,
    required super.selectedDesignations,
    required super.selectedUsers,
  });
}

class AudienceLoaded extends AudienceState {
  final List<String> items;

  const AudienceLoaded({
    required super.activeTab,
    required super.searchQuery,
    required super.selectedDepartments,
    required super.selectedDesignations,
    required super.selectedUsers,
    required this.items,
  });

  AudienceLoaded copyWith({
    AudienceTab? activeTab,
    String? searchQuery,
    Set<String>? selectedDepartments,
    Set<String>? selectedDesignations,
    Set<String>? selectedUsers,
    List<String>? items,
  }) {
    return AudienceLoaded(
      activeTab: activeTab ?? this.activeTab,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedDepartments: selectedDepartments ?? this.selectedDepartments,
      selectedDesignations:
          selectedDesignations ?? this.selectedDesignations,
      selectedUsers: selectedUsers ?? this.selectedUsers,
      items: items ?? this.items,
    );
  }
}

class AudienceError extends AudienceState {
  final String message;

  const AudienceError({
    required super.activeTab,
    required super.searchQuery,
    required super.selectedDepartments,
    required super.selectedDesignations,
    required super.selectedUsers,
    required this.message,
  });
}
