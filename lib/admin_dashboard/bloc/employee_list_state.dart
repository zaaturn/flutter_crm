import 'package:equatable/equatable.dart';
import 'package:my_app/admin_dashboard/model/employee.dart';

enum EmployeeListStatus { initial, loading, success, failure, loadingMore }

class EmployeeListState extends Equatable {
  final EmployeeListStatus status;
  final List<Employee> employees;
  final int currentPage;
  final bool hasMore;
  final int totalCount;
  final String? selectedRole;
  final String searchQuery;
  final String? errorMessage;
  final Map<int, bool> liveStatusMap;

  const EmployeeListState({
    this.status = EmployeeListStatus.initial,
    this.employees = const [],
    this.currentPage = 1,
    this.hasMore = true,
    this.totalCount = 0,
    this.selectedRole,
    this.searchQuery = '',
    this.errorMessage,
    this.liveStatusMap = const {},
  });

  EmployeeListState copyWith({
    EmployeeListStatus? status,
    List<Employee>? employees,
    int? currentPage,
    bool? hasMore,
    int? totalCount,
    String? selectedRole,
    bool clearRole = false,
    String? searchQuery,
    String? errorMessage,
    Map<int, bool>? liveStatusMap,
  }) {
    return EmployeeListState(
      status: status ?? this.status,
      employees: employees ?? this.employees,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      totalCount: totalCount ?? this.totalCount,
      selectedRole: clearRole ? null : selectedRole ?? this.selectedRole,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
      liveStatusMap: liveStatusMap ?? this.liveStatusMap,
    );
  }

  List<Employee> get employeesWithStatus {
    return employees.map((e) {
      final online = liveStatusMap[e.id] ?? false;
      return e.copyWith(isActive: online);
    }).toList();
  }

  @override
  List<Object?> get props => [
    status,
    employees,
    currentPage,
    hasMore,
    totalCount,
    selectedRole,
    searchQuery,
    errorMessage,
    liveStatusMap,
  ];
}
