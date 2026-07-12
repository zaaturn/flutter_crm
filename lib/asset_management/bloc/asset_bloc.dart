import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/asset_repository.dart';
import '../services/asset_api_service.dart';
import 'asset_event.dart';
import 'asset_state.dart';

class AssetBloc extends Bloc<AssetEvent, AssetState> {
  AssetBloc({
    AssetRepository? repository,
    bool isAdmin = false,
    AssetShellTab? initialTab,
  })  : _repo = repository ?? AssetRepository(),
        super(AssetState(
          isAdmin: isAdmin,
          tab: initialTab ??
              (isAdmin ? AssetShellTab.dashboard : AssetShellTab.myAssets),
        )) {
    on<AssetShellStarted>(_onStarted);
    on<AssetTabChanged>(_onTabChanged);
    on<AssetRefreshRequested>(_onRefresh);
    on<AssetListFilterChanged>(_onFilterChanged);
    on<AssetSearchQueryChanged>(_onSearch);
    on<AssetCreateSubmitted>(_onCreate);
    on<AssetApproveRequest>(_onApproveRequest);
    on<AssetRejectRequest>(_onRejectRequest);
    on<AssetVerifyReturn>(_onVerifyReturn);
    on<AssetRejectReturn>(_onRejectReturn);
    on<AssetStartRepair>(_onStartRepair);
    on<AssetCompleteRepair>(_onCompleteRepair);
    on<AssetCalendarMonthChanged>(_onCalendarMonth);
    on<AssetSelectionToggled>(_onToggleSelection);
    on<AssetClearSelection>(_onClearSelection);
    on<AssetDeleteRequested>(_onDelete);
  }

  final AssetRepository _repo;

  Future<void> _onStarted(
    AssetShellStarted event,
    Emitter<AssetState> emit,
  ) async {
    final now = DateTime.now();
    final initialTab = event.initialTab ??
        (event.isAdmin ? AssetShellTab.dashboard : AssetShellTab.myAssets);
    emit(state.copyWith(
      isAdmin: event.isAdmin,
      tab: initialTab,
      calendarYear: now.year,
      calendarMonth: now.month,
      clearError: true,
    ));
    await _loadForTab(emit, initialTab);
  }

  Future<void> _onTabChanged(
    AssetTabChanged event,
    Emitter<AssetState> emit,
  ) async {
    emit(state.copyWith(tab: event.tab, clearError: true, clearSuccess: true));
    await _loadForTab(emit, event.tab);
  }

  Future<void> _onRefresh(
    AssetRefreshRequested event,
    Emitter<AssetState> emit,
  ) async {
    await _loadForTab(emit, state.tab);
  }

  Future<void> _onFilterChanged(
    AssetListFilterChanged event,
    Emitter<AssetState> emit,
  ) async {
    emit(state.copyWith(
      statusFilter: event.status,
      typeFilter: event.assetType,
      clearStatusFilter: event.status == null,
      clearTypeFilter: event.assetType == null,
    ));
    await _loadInventory(emit);
  }

  Future<void> _onSearch(
    AssetSearchQueryChanged event,
    Emitter<AssetState> emit,
  ) async {
    final q = event.query.trim();
    emit(state.copyWith(searchQuery: q, clearError: true));
    if (q.isEmpty) {
      emit(state.copyWith(searchResults: const [], loading: false));
      return;
    }
    emit(state.copyWith(loading: true));
    try {
      final results = await _repo.search(q);
      emit(state.copyWith(loading: false, searchResults: results));
    } catch (e) {
      emit(state.copyWith(loading: false, error: _msg(e)));
    }
  }

  Future<void> _onCreate(
    AssetCreateSubmitted event,
    Emitter<AssetState> emit,
  ) async {
    emit(state.copyWith(
      actionLoading: true,
      clearError: true,
      clearLastCreated: true,
    ));
    try {
      final created = await _repo.createAsset(event.payload);
      emit(state.copyWith(
        actionLoading: false,
        lastCreatedAsset: created,
        successMessage: 'Asset created successfully',
      ));
      await _loadInventory(emit);
    } catch (e) {
      emit(state.copyWith(actionLoading: false, error: _msg(e)));
    }
  }

  Future<void> _onApproveRequest(
    AssetApproveRequest event,
    Emitter<AssetState> emit,
  ) async {
    emit(state.copyWith(actionLoading: true, clearError: true, clearSuccess: true));
    final previous = state.pendingRequests;
    emit(state.copyWith(
      pendingRequests:
          previous.where((r) => r.id != event.id).toList(),
    ));
    try {
      await _repo.approveRequest(event.id);
      emit(state.copyWith(
        actionLoading: false,
        successMessage: 'Request approved',
      ));
    } catch (e) {
      emit(state.copyWith(
        actionLoading: false,
        pendingRequests: previous,
        error: _msg(e),
      ));
    }
  }

  Future<void> _onRejectRequest(
    AssetRejectRequest event,
    Emitter<AssetState> emit,
  ) async {
    emit(state.copyWith(actionLoading: true, clearError: true, clearSuccess: true));
    final previous = state.pendingRequests;
    emit(state.copyWith(
      pendingRequests:
          previous.where((r) => r.id != event.id).toList(),
    ));
    try {
      await _repo.rejectRequest(event.id, comment: event.comment);
      emit(state.copyWith(
        actionLoading: false,
        successMessage: 'Request rejected',
      ));
    } catch (e) {
      emit(state.copyWith(
        actionLoading: false,
        pendingRequests: previous,
        error: _msg(e),
      ));
    }
  }

  Future<void> _onVerifyReturn(
    AssetVerifyReturn event,
    Emitter<AssetState> emit,
  ) async {
    emit(state.copyWith(actionLoading: true, clearError: true, clearSuccess: true));
    final previous = state.pendingReturns;
    emit(state.copyWith(
      pendingReturns: previous.where((r) => r.id != event.id).toList(),
    ));
    try {
      await _repo.verifyReturn(event.id);
      emit(state.copyWith(
        actionLoading: false,
        successMessage: 'Return verified',
      ));
    } catch (e) {
      emit(state.copyWith(
        actionLoading: false,
        pendingReturns: previous,
        error: _msg(e),
      ));
    }
  }

  Future<void> _onRejectReturn(
    AssetRejectReturn event,
    Emitter<AssetState> emit,
  ) async {
    emit(state.copyWith(actionLoading: true, clearError: true, clearSuccess: true));
    final previous = state.pendingReturns;
    emit(state.copyWith(
      pendingReturns: previous.where((r) => r.id != event.id).toList(),
    ));
    try {
      await _repo.rejectReturn(event.id, comment: event.comment);
      emit(state.copyWith(
        actionLoading: false,
        successMessage: 'Return rejected',
      ));
    } catch (e) {
      emit(state.copyWith(
        actionLoading: false,
        pendingReturns: previous,
        error: _msg(e),
      ));
    }
  }

  Future<void> _onStartRepair(
    AssetStartRepair event,
    Emitter<AssetState> emit,
  ) async {
    await _runAction(emit, () => _repo.startRepair(event.id), 'Repair started');
    await _loadPendingDamage(emit);
  }

  Future<void> _onCompleteRepair(
    AssetCompleteRepair event,
    Emitter<AssetState> emit,
  ) async {
    await _runAction(
      emit,
      () => _repo.completeRepair(event.id, resolutionNotes: event.notes),
      'Repair completed',
    );
    await _loadPendingDamage(emit);
  }

  Future<void> _onCalendarMonth(
    AssetCalendarMonthChanged event,
    Emitter<AssetState> emit,
  ) async {
    emit(state.copyWith(
      calendarYear: event.year,
      calendarMonth: event.month,
    ));
    await _loadCalendar(emit, event.year, event.month);
  }

  void _onToggleSelection(
    AssetSelectionToggled event,
    Emitter<AssetState> emit,
  ) {
    final next = Set<String>.from(state.selectedCodes);
    if (next.contains(event.assetCode)) {
      next.remove(event.assetCode);
    } else {
      next.add(event.assetCode);
    }
    emit(state.copyWith(selectedCodes: next));
  }

  void _onClearSelection(
    AssetClearSelection event,
    Emitter<AssetState> emit,
  ) {
    emit(state.copyWith(selectedCodes: const {}));
  }

  Future<void> _onDelete(
    AssetDeleteRequested event,
    Emitter<AssetState> emit,
  ) async {
    emit(state.copyWith(actionLoading: true, clearError: true, clearSuccess: true));
    try {
      await _repo.deleteAsset(
        event.assetCode,
        reason: event.reason,
      );
      final next = Set<String>.from(state.selectedCodes)..remove(event.assetCode);
      emit(state.copyWith(
        actionLoading: false,
        selectedCodes: next,
        assets: state.assets
            .where((a) => a.assetCode != event.assetCode)
            .toList(),
        successMessage: 'Asset deleted',
      ));
      if (state.tab == AssetShellTab.dashboard) {
        await _loadDashboard(emit);
      }
    } catch (e) {
      emit(state.copyWith(actionLoading: false, error: _msg(e)));
    }
  }

  Future<void> _loadForTab(Emitter<AssetState> emit, AssetShellTab tab) async {
    switch (tab) {
      case AssetShellTab.dashboard:
        await _loadDashboard(emit);
      case AssetShellTab.inventory:
        await _loadInventory(emit);
      case AssetShellTab.myAssets:
        await _loadMyAssets(emit);
      case AssetShellTab.scan:
        break;
      case AssetShellTab.search:
        if (state.searchQuery.isNotEmpty) {
          add(AssetSearchQueryChanged(state.searchQuery));
        }
      case AssetShellTab.calendar:
        final y = state.calendarYear ?? DateTime.now().year;
        final m = state.calendarMonth ?? DateTime.now().month;
        await _loadCalendar(emit, y, m);
      case AssetShellTab.pendingRequests:
        await _loadPendingRequests(emit);
      case AssetShellTab.pendingReturns:
        await _loadPendingReturns(emit);
      case AssetShellTab.pendingDamage:
        await _loadPendingDamage(emit);
      case AssetShellTab.guests:
        break;
    }
  }

  Future<void> _loadDashboard(Emitter<AssetState> emit) async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final stats = await _repo.dashboard();
      final byDept = await _repo.reportByDepartment();
      final byEmp = await _repo.reportByEmployee();
      emit(state.copyWith(
        loading: false,
        dashboard: stats,
        byDepartment: byDept,
        byEmployee: byEmp,
      ));
    } catch (e) {
      emit(state.copyWith(loading: false, error: _msg(e)));
    }
  }

  Future<void> _loadInventory(Emitter<AssetState> emit) async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final list = await _repo.listAssets(
        status: state.statusFilter,
        assetType: state.typeFilter,
      );
      emit(state.copyWith(loading: false, assets: list));
    } catch (e) {
      emit(state.copyWith(loading: false, error: _msg(e)));
    }
  }

  Future<void> _loadMyAssets(Emitter<AssetState> emit) async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final list = await _repo.myAssets();
      emit(state.copyWith(loading: false, myAssets: list));
    } catch (e) {
      emit(state.copyWith(loading: false, error: _msg(e)));
    }
  }

  Future<void> _loadPendingRequests(Emitter<AssetState> emit) async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final list = await _repo.pendingRequests();
      emit(state.copyWith(loading: false, pendingRequests: list));
    } catch (e) {
      emit(state.copyWith(loading: false, error: _msg(e)));
    }
  }

  Future<void> _loadPendingReturns(Emitter<AssetState> emit) async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final list = await _repo.pendingReturns();
      emit(state.copyWith(loading: false, pendingReturns: list));
    } catch (e) {
      emit(state.copyWith(loading: false, error: _msg(e)));
    }
  }

  Future<void> _loadPendingDamage(Emitter<AssetState> emit) async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final list = await _repo.pendingDamage();
      emit(state.copyWith(loading: false, pendingDamage: list));
    } catch (e) {
      emit(state.copyWith(loading: false, error: _msg(e)));
    }
  }

  Future<void> _loadCalendar(
    Emitter<AssetState> emit,
    int year,
    int month,
  ) async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final list = await _repo.calendar(year: year, month: month);
      emit(state.copyWith(loading: false, calendarEvents: list));
    } catch (e) {
      emit(state.copyWith(loading: false, error: _msg(e)));
    }
  }

  Future<void> _runAction(
    Emitter<AssetState> emit,
    Future<void> Function() action,
    String success,
  ) async {
    emit(state.copyWith(actionLoading: true, clearError: true));
    try {
      await action();
      emit(state.copyWith(
        actionLoading: false,
        successMessage: success,
      ));
    } catch (e) {
      emit(state.copyWith(actionLoading: false, error: _msg(e)));
    }
  }

  String _msg(Object e) {
    if (e is AssetApiException) return e.message;
    return e.toString().replaceFirst('Exception: ', '');
  }
}
