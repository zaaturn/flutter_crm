import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_app/dashboards/widgets/audience_tab.dart';
import 'package:my_app/dashboards/domain/models/user_entity.dart';
import 'package:my_app/dashboards/domain/repository/user_repository.dart';
import 'audience_event.dart';
import 'audience_state.dart';

class AudienceBloc extends Bloc<AudienceEvent, AudienceState> {
  final UserRepository userRepository;
  Timer? _debounce;

  /// Name → id for each dimension (merged on fetch so selections stay resolvable).
  final Map<String, int> _departmentIdMap = {};
  final Map<String, int> _designationIdMap = {};
  final Map<String, int> _userIdMap = {};

  AudienceBloc({required this.userRepository})
      : super(const AudienceInitial()) {
    on<AudienceTabChanged>(_onTabChanged);
    on<AudienceSearchChanged>(_onSearchChanged);
    on<AudienceFetchDebounced>(_onFetchDebounced);
    on<AudienceItemToggled>(_onItemToggled);
    on<AudienceSelectAllToggled>(_onSelectAllToggled);
    on<AudienceSelectionCleared>(_onSelectionCleared);

    add(AudienceTabChanged(AudienceTab.byDepartment));
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }

  void _emitLoadingForTab(
    Emitter<AudienceState> emit,
    AudienceTab tab, {
    String searchQuery = '',
  }) {
    emit(AudienceLoading(
      activeTab: tab,
      searchQuery: searchQuery,
      selectedDepartments: state.selectedDepartments,
      selectedDesignations: state.selectedDesignations,
      selectedUsers: state.selectedUsers,
    ));
  }

  Future<void> _onTabChanged(
    AudienceTabChanged event,
    Emitter<AudienceState> emit,
  ) async {
    _emitLoadingForTab(emit, event.tab, searchQuery: '');
    await _fetch(emit, tab: event.tab, query: '');
  }

  void _onSearchChanged(
    AudienceSearchChanged event,
    Emitter<AudienceState> emit,
  ) {
    _emitLoadingForTab(emit, state.activeTab, searchQuery: event.query);

    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 400),
      () => add(AudienceFetchDebounced(event.query)),
    );
  }

  Future<void> _onFetchDebounced(
    AudienceFetchDebounced event,
    Emitter<AudienceState> emit,
  ) async {
    await _fetch(emit, tab: state.activeTab, query: event.query);
  }

  void _onItemToggled(
    AudienceItemToggled event,
    Emitter<AudienceState> emit,
  ) {
    if (state is! AudienceLoaded) return;

    final tab = state.activeTab;
    final sel = state.selectionFor(tab);
    final updated = Set<String>.from(sel);
    if (updated.contains(event.item)) {
      updated.remove(event.item);
    } else {
      updated.add(event.item);
    }

    final nextDepartments = tab == AudienceTab.byDepartment
        ? updated
        : state.selectedDepartments;
    final nextDesignations = tab == AudienceTab.byDesignation
        ? updated
        : state.selectedDesignations;
    final nextUsers =
        tab == AudienceTab.specificUsers ? updated : state.selectedUsers;

    emit((state as AudienceLoaded).copyWith(
      selectedDepartments: nextDepartments,
      selectedDesignations: nextDesignations,
      selectedUsers: nextUsers,
    ));
  }

  void _onSelectAllToggled(
    AudienceSelectAllToggled event,
    Emitter<AudienceState> emit,
  ) {
    if (state is! AudienceLoaded) return;
    final s = state as AudienceLoaded;
    final tab = s.activeTab;

    final currentSel = s.selectionFor(tab);
    final updated = Set<String>.from(currentSel);

    if (event.select) {
      // Select all currently visible items.
      updated.addAll(s.items);
    } else {
      // Deselect all currently visible items.
      updated.removeAll(s.items);
    }

    emit(s.copyWith(
      selectedDepartments:
          tab == AudienceTab.byDepartment ? updated : s.selectedDepartments,
      selectedDesignations:
          tab == AudienceTab.byDesignation ? updated : s.selectedDesignations,
      selectedUsers:
          tab == AudienceTab.specificUsers ? updated : s.selectedUsers,
    ));
  }

  void _onSelectionCleared(
    AudienceSelectionCleared event,
    Emitter<AudienceState> emit,
  ) {
    if (state is! AudienceLoaded) return;
    final s = state as AudienceLoaded;
    final t = event.onlyTab;
    if (t == null) {
      emit(s.copyWith(
        selectedDepartments: {},
        selectedDesignations: {},
        selectedUsers: {},
      ));
      return;
    }
    if (t == AudienceTab.byDepartment) {
      emit(s.copyWith(selectedDepartments: {}));
    } else if (t == AudienceTab.byDesignation) {
      emit(s.copyWith(selectedDesignations: {}));
    } else {
      emit(s.copyWith(selectedUsers: {}));
    }
  }

  Future<void> _fetch(
    Emitter<AudienceState> emit, {
    required AudienceTab tab,
    required String query,
  }) async {
    final departments = state.selectedDepartments;
    final designations = state.selectedDesignations;
    final users = state.selectedUsers;

    try {
      if (kDebugMode) {
        debugPrint('[Audience] fetch tab=$tab query="$query"');
      }
      final items = await _loadItems(tab: tab, query: query);
      if (kDebugMode) {
        debugPrint('[Audience] loaded tab=$tab items=${items.length}'
            ' sample=${items.take(3).toList()}');
      }

      emit(AudienceLoaded(
        activeTab: tab,
        searchQuery: query,
        selectedDepartments: departments,
        selectedDesignations: designations,
        selectedUsers: users,
        items: items,
      ));
    } catch (e) {
      emit(AudienceError(
        activeTab: tab,
        searchQuery: query,
        selectedDepartments: departments,
        selectedDesignations: designations,
        selectedUsers: users,
        message: e.toString(),
      ));
    }
  }

  static String _normPrefix(String query) => query.trim().toLowerCase();

  static bool _nameStartsWith(String raw, String qLower) {
    if (qLower.isEmpty) return true;
    return raw.trim().toLowerCase().startsWith(qLower);
  }

  static bool _userMatchesNamePrefix(UserEntity u, String qLower) {
    if (qLower.isEmpty) return true;
    if (_nameStartsWith(u.displayLabel, qLower)) return true;
    if (u.fullName != null && _nameStartsWith(u.fullName!, qLower)) {
      return true;
    }
    if (u.firstName != null && _nameStartsWith(u.firstName!, qLower)) {
      return true;
    }
    if (u.lastName != null && _nameStartsWith(u.lastName!, qLower)) return true;
    final combined = [u.firstName, u.lastName]
        .whereType<String>()
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .join(' ');
    if (combined.isNotEmpty && _nameStartsWith(combined, qLower)) return true;
    if (_nameStartsWith(u.username, qLower)) return true;
    if (_nameStartsWith(u.email, qLower)) return true;
    return false;
  }

  Future<List<String>> _loadItems({
    required AudienceTab tab,
    required String query,
  }) async {
    // Do not pass `search` to the API — several backends 400 or use non-prefix
    // semantics. We fetch lists (users already fully paginated) and filter here
    // so typing "sum" shows every name that *starts with* "sum" (case-insensitive).
    final qLower = _normPrefix(query);

    switch (tab) {
      case AudienceTab.byDepartment:
        final list = await userRepository.getDepartments(search: null);
        final filtered = qLower.isEmpty
            ? list
            : list.where((d) => _nameStartsWith(d.name, qLower)).toList();
        for (final d in filtered) {
          _departmentIdMap[d.name] = d.id;
        }
        return filtered.map((d) => d.name).toList();

      case AudienceTab.byDesignation:
        final list = await userRepository.getDesignations(search: null);
        final filtered = qLower.isEmpty
            ? list
            : list.where((d) => _nameStartsWith(d.name, qLower)).toList();
        for (final d in filtered) {
          _designationIdMap[d.name] = d.id;
        }
        return filtered.map((d) => d.name).toList();

      case AudienceTab.specificUsers:
        final list = await userRepository.getUsers(search: null);
        final filtered = qLower.isEmpty
            ? list
            : list.where((u) => _userMatchesNamePrefix(u, qLower)).toList();
        final names = <String>[];
        for (final u in filtered) {
          var label = u.displayLabel;
          if (_userIdMap.containsKey(label) &&
              _userIdMap[label] != u.id) {
            label = '${u.displayLabel} (#${u.id})';
          }
          _userIdMap[label] = u.id;
          names.add(label);
        }
        names.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
        return names;
    }
  }

  /// Maps all three targeting dimensions to API ID lists.
  ({List<int> userIds, List<int> departmentIds, List<int> designationIds})
      resolveCreatePostTargeting() {
    final deptIds = state.selectedDepartments
        .map((n) => _departmentIdMap[n])
        .whereType<int>()
        .toList();
    final desigIds = state.selectedDesignations
        .map((n) => _designationIdMap[n])
        .whereType<int>()
        .toList();
    final userIds = state.selectedUsers
        .map((n) => _userIdMap[n])
        .whereType<int>()
        .toList();
    return (
      userIds: userIds,
      departmentIds: deptIds,
      designationIds: desigIds,
    );
  }
}
