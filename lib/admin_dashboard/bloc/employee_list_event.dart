// lib/bloc/employee_list/employee_list_event.dart
import 'package:equatable/equatable.dart';

abstract class EmployeeListEvent extends Equatable {
  const EmployeeListEvent();

  @override
  List<Object?> get props => [];
}

class FetchEmployees extends EmployeeListEvent {
  const FetchEmployees();
}

class LoadMoreEmployees extends EmployeeListEvent {
  const LoadMoreEmployees();
}

class RefreshEmployees extends EmployeeListEvent {
  const RefreshEmployees();
}

class FilterByRole extends EmployeeListEvent {
  final String? role;
  const FilterByRole(this.role);

  @override
  List<Object?> get props => [role];
}

class SearchEmployees extends EmployeeListEvent {
  final String query;
  const SearchEmployees(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearFilters extends EmployeeListEvent {
  const ClearFilters();
}

class FetchLiveStatus extends EmployeeListEvent {
  const FetchLiveStatus();
}