import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_app/dashboards/widgets/audience_tab.dart';
import 'package:my_app/dashboards/domain/repository/user_repository.dart';
import 'audience_event.dart';
import 'audience_state.dart';

class AudienceBloc extends Bloc<AudienceEvent, AudienceState> {
  final UserRepository userRepository;
  Timer? _debounce;

  AudienceBloc({required this.userRepository})
      : super(const AudienceInitial()) {
    on<AudienceTabChanged>(_onTabChanged);
    on<AudienceSearchChanged>(_onSearchChanged);
    on<AudienceFetchDebounced>(_onFetchDebounced);
    on<AudienceItemToggled>(_onItemToggled);
    on<AudienceSelectionCleared>(_onSelectionCleared);

    // Load initial department list on creation
    add(AudienceTabChanged(AudienceTab.byDepartment));
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }

  // ── Handlers ───────────────────────────────────────────────────────────────

  Future<void> _onTabChanged(
      AudienceTabChanged event,
      Emitter<AudienceState> emit,
      ) async {
    emit(AudienceLoading(
      activeTab: event.tab,
      searchQuery: '',
      selected: const {},
    ));
    await _fetch(emit, tab: event.tab, query: '');
  }

  void _onSearchChanged(
      AudienceSearchChanged event,
      Emitter<AudienceState> emit,
      ) {
    // Show spinner immediately while debouncing
    emit(AudienceLoading(
      activeTab: state.activeTab,
      searchQuery: event.query,
      selected: state.selected,
    ));

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
    final updated = Set<String>.from(state.selected);
    updated.contains(event.item)
        ? updated.remove(event.item)
        : updated.add(event.item);

    if (state is AudienceLoaded) {
      emit((state as AudienceLoaded).copyWith(selected: updated));
    }
  }

  void _onSelectionCleared(
      AudienceSelectionCleared event,
      Emitter<AudienceState> emit,
      ) {
    if (state is AudienceLoaded) {
      emit((state as AudienceLoaded).copyWith(selected: {}));
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<void> _fetch(
      Emitter<AudienceState> emit, {
        required AudienceTab tab,
        required String query,
      }) async {
    try {
      final items = await _loadItems(tab: tab, query: query);
      emit(AudienceLoaded(
        activeTab: tab,
        searchQuery: query,
        selected: state.selected,
        items: items,
      ));
    } catch (e) {
      emit(AudienceError(
        activeTab: tab,
        searchQuery: query,
        selected: state.selected,
        message: e.toString(),
      ));
    }
  }

  Future<List<String>> _loadItems({
    required AudienceTab tab,
    required String query,
  }) async {
    final search = query.isEmpty ? null : query;
    switch (tab) {
      case AudienceTab.byDepartment:
        final list = await userRepository.getDepartments(search: search);
        return list.map((d) => d.name).toList();
      case AudienceTab.byDesignation:
        final list = await userRepository.getDesignations(search: search);
        return list.map((d) => d.name).toList();
      case AudienceTab.specificUsers:
        final list = await userRepository.getUsers(search: search);
        return list
            .map((u) =>
            [u.firstName, u.lastName].whereType<String>().join(' ').trim())
            .where((name) => name.isNotEmpty)
            .toList();
    }
  }
}