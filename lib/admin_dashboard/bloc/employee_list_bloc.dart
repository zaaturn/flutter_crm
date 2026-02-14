// lib/bloc/employee_list/employee_list_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/admin_dashboard/repository/employee_list_repository.dart';

import 'employee_list_event.dart';
import 'employee_list_state.dart';

class EmployeeListBloc extends Bloc<EmployeeListEvent, EmployeeListState> {
  final IEmployeeRepository _repository;
  Timer? _searchDebounce;

  EmployeeListBloc({required IEmployeeRepository repository})
      : _repository = repository,
        super(const EmployeeListState()) {
    on<FetchEmployees>(_onFetchEmployees);
    on<LoadMoreEmployees>(_onLoadMoreEmployees);
    on<RefreshEmployees>(_onRefreshEmployees);
    on<FilterByRole>(_onFilterByRole);
    on<SearchEmployees>(_onSearchEmployees);
    on<ClearFilters>(_onClearFilters);
    on<FetchLiveStatus>(_onFetchLiveStatus);
  }

  Future<void> _onFetchEmployees(
      FetchEmployees event,
      Emitter<EmployeeListState> emit,
      ) async {
    print("Bloc: FetchEmployees triggered");
    emit(state.copyWith(status: EmployeeListStatus.loading));
    try {
      final response = await _repository.getEmployees(
        page: 1,
        role: state.selectedRole,
        search: state.searchQuery.isEmpty ? null : state.searchQuery,
      );
      emit(state.copyWith(
        status: EmployeeListStatus.success,
        employees: response.results,
        currentPage: 1,
        hasMore: response.hasMore,
        totalCount: response.count,
      ));
      add(const FetchLiveStatus());
    } catch (e) {
      emit(state.copyWith(
        status: EmployeeListStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onLoadMoreEmployees(
      LoadMoreEmployees event,
      Emitter<EmployeeListState> emit,
      ) async {
    if (state.status == EmployeeListStatus.loadingMore || !state.hasMore) return;
    emit(state.copyWith(status: EmployeeListStatus.loadingMore));
    try {
      final nextPage = state.currentPage + 1;
      final response = await _repository.getEmployees(
        page: nextPage,
        role: state.selectedRole,
        search: state.searchQuery.isEmpty ? null : state.searchQuery,
      );
      emit(state.copyWith(
        status: EmployeeListStatus.success,
        employees: [...state.employees, ...response.results],
        currentPage: nextPage,
        hasMore: response.hasMore,
        totalCount: response.count,
      ));
      add(const FetchLiveStatus());
    } catch (e) {
      emit(state.copyWith(
        status: EmployeeListStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRefreshEmployees(
      RefreshEmployees event,
      Emitter<EmployeeListState> emit,
      ) async {
    emit(state.copyWith(
      status: EmployeeListStatus.loading,
      employees: [],
      currentPage: 1,
    ));
    try {
      final response = await _repository.getEmployees(
        page: 1,
        role: state.selectedRole,
        search: state.searchQuery.isEmpty ? null : state.searchQuery,
      );
      emit(state.copyWith(
        status: EmployeeListStatus.success,
        employees: response.results,
        currentPage: 1,
        hasMore: response.hasMore,
        totalCount: response.count,
      ));
      add(const FetchLiveStatus());
    } catch (e) {
      emit(state.copyWith(
        status: EmployeeListStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onFilterByRole(
      FilterByRole event,
      Emitter<EmployeeListState> emit,
      ) async {
    final newRole = event.role == state.selectedRole ? null : event.role;
    emit(state.copyWith(
      selectedRole: newRole,
      clearRole: newRole == null,
      employees: [],
      currentPage: 1,
      status: EmployeeListStatus.loading,
    ));
    try {
      final response = await _repository.getEmployees(
        page: 1,
        role: newRole,
        search: state.searchQuery.isEmpty ? null : state.searchQuery,
      );
      emit(state.copyWith(
        status: EmployeeListStatus.success,
        employees: response.results,
        currentPage: 1,
        hasMore: response.hasMore,
        totalCount: response.count,
      ));
      add(const FetchLiveStatus());
    } catch (e) {
      emit(state.copyWith(
        status: EmployeeListStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onSearchEmployees(
      SearchEmployees event,
      Emitter<EmployeeListState> emit,
      ) {
    _searchDebounce?.cancel();
    emit(state.copyWith(searchQuery: event.query));
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      add(const FetchEmployees());
    });
  }

  Future<void> _onClearFilters(
      ClearFilters event,
      Emitter<EmployeeListState> emit,
      ) async {
    emit(state.copyWith(
      clearRole: true,
      searchQuery: '',
      employees: [],
      currentPage: 1,
      status: EmployeeListStatus.loading,
    ));
    try {
      final response = await _repository.getEmployees(page: 1);
      emit(state.copyWith(
        status: EmployeeListStatus.success,
        employees: response.results,
        currentPage: 1,
        hasMore: response.hasMore,
        totalCount: response.count,
      ));
      add(const FetchLiveStatus());
    } catch (e) {
      emit(state.copyWith(
        status: EmployeeListStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
  Future<void> _onFetchLiveStatus(
      FetchLiveStatus event,
      Emitter<EmployeeListState> emit,
      ) async {
    try {
      final statusMap = await _repository.getLiveStatus();

      final boolMap = statusMap.map(
            (key, value) => MapEntry(
          key,
          value['liveStatus'] as bool? ?? false,
        ),
      );

      emit(state.copyWith(liveStatusMap: boolMap));
    } catch (_) {}
  }


  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }
}