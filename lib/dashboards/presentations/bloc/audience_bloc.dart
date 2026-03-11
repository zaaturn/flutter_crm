import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_app/dashboards/widgets/audience_tab.dart';
import 'package:my_app/dashboards/domain/repository/user_repository.dart';
import 'audience_event.dart';
import 'audience_state.dart';

class AudienceBloc extends Bloc<AudienceEvent, AudienceState> {
  final UserRepository userRepository;
  Timer? _debounce;

  // Store ID mapping
  final Map<String, int> _itemIdMap = {};

  AudienceBloc({required this.userRepository})
      : super(const AudienceInitial()) {
    on<AudienceTabChanged>(_onTabChanged);
    on<AudienceSearchChanged>(_onSearchChanged);
    on<AudienceFetchDebounced>(_onFetchDebounced);
    on<AudienceItemToggled>(_onItemToggled);
    on<AudienceSelectionCleared>(_onSelectionCleared);

    add(AudienceTabChanged(AudienceTab.byDepartment));
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }

  // ── Handlers ─────────────────────────────────────

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

    if (updated.contains(event.item)) {
      updated.remove(event.item);
    } else {
      updated.add(event.item);
    }

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

  // ── Fetch helper ─────────────────────────────────

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

  // ── Load API items ───────────────────────────────

  Future<List<String>> _loadItems({
    required AudienceTab tab,
    required String query,
  }) async {
    final search = query.isEmpty ? null : query;

    _itemIdMap.clear();

    switch (tab) {
      case AudienceTab.byDepartment:
        final list = await userRepository.getDepartments(search: search);

        for (var d in list) {
          _itemIdMap[d.name] = d.id;
        }

        return list.map((d) => d.name).toList();

      case AudienceTab.byDesignation:
        final list = await userRepository.getDesignations(search: search);

        for (var d in list) {
          _itemIdMap[d.name] = d.id;
        }

        return list.map((d) => d.name).toList();

      case AudienceTab.specificUsers:
        final list = await userRepository.getUsers(search: search);

        for (var u in list) {
          final name =
          [u.firstName, u.lastName].whereType<String>().join(' ').trim();

          if (name.isNotEmpty) {
            _itemIdMap[name] = u.id;
          }
        }

        return _itemIdMap.keys.toList();
    }
  }

  // ── Helper to get IDs for API ────────────────────

  List<int> getSelectedIds() {
    return state.selected
        .map((name) => _itemIdMap[name])
        .whereType<int>()
        .toList();
  }
}