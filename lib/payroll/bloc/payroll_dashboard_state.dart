import 'package:equatable/equatable.dart';

import '../models/payroll_dashboard_model.dart';
import '../models/payroll_employee_option.dart';
import '../models/payroll_merged_row.dart';
import '../models/payroll_record_model.dart';
import '../models/payroll_records_paid_filter.dart';

enum PayrollDashboardLoadStatus { initial, loading, success, failure }

class PayrollDashboardState extends Equatable {
  const PayrollDashboardState({
    required this.loadStatus,
    required this.dashboard,
    required this.tableRows,
    required this.searchQuery,
    required this.monthIndex,
    required this.year,
    this.recordsPaidFilter = PayrollRecordsPaidFilter.all,
    this.errorMessage,
    this.employeeOptions = const [],
    this.periodRecords = const [],
    this.savingRecordId,
    this.savingEmployeeId,
  });

  factory PayrollDashboardState.initial() {
    final now = DateTime.now();
    return PayrollDashboardState(
      loadStatus: PayrollDashboardLoadStatus.initial,
      dashboard: PayrollDashboardModel.empty(now.year),
      tableRows: const [],
      searchQuery: '',
      monthIndex: now.month,
      year: now.year,
      recordsPaidFilter: PayrollRecordsPaidFilter.all,
      employeeOptions: const [],
      periodRecords: const [],
      savingRecordId: null,
      savingEmployeeId: null,
    );
  }

  final PayrollDashboardLoadStatus loadStatus;
  final PayrollDashboardModel dashboard;
  /// One row per employee for [monthIndex] + [year], merged with API records.
  final List<PayrollMergedRow> tableRows;
  final String searchQuery;
  /// 1–12 only (set from top bar).
  final int monthIndex;
  final int year;
  final PayrollRecordsPaidFilter recordsPaidFilter;
  final String? errorMessage;
  final List<PayrollEmployeeOption> employeeOptions;
  /// Raw payroll rows for current month/year (for re-merge on search).
  final List<PayrollRecordModel> periodRecords;
  final int? savingRecordId;
  final int? savingEmployeeId;

  PayrollDashboardState copyWith({
    PayrollDashboardLoadStatus? loadStatus,
    PayrollDashboardModel? dashboard,
    List<PayrollMergedRow>? tableRows,
    String? searchQuery,
    int? monthIndex,
    int? year,
    PayrollRecordsPaidFilter? recordsPaidFilter,
    String? errorMessage,
    bool clearError = false,
    List<PayrollEmployeeOption>? employeeOptions,
    List<PayrollRecordModel>? periodRecords,
    int? savingRecordId,
    int? savingEmployeeId,
    bool clearSavingRecordId = false,
    bool clearSavingEmployeeId = false,
  }) {
    return PayrollDashboardState(
      loadStatus: loadStatus ?? this.loadStatus,
      dashboard: dashboard ?? this.dashboard,
      tableRows: tableRows ?? this.tableRows,
      searchQuery: searchQuery ?? this.searchQuery,
      monthIndex: monthIndex ?? this.monthIndex,
      year: year ?? this.year,
      recordsPaidFilter: recordsPaidFilter ?? this.recordsPaidFilter,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      employeeOptions: employeeOptions ?? this.employeeOptions,
      periodRecords: periodRecords ?? this.periodRecords,
      savingRecordId: clearSavingRecordId
          ? null
          : (savingRecordId ?? this.savingRecordId),
      savingEmployeeId: clearSavingEmployeeId
          ? null
          : (savingEmployeeId ?? this.savingEmployeeId),
    );
  }

  @override
  List<Object?> get props => [
        loadStatus,
        dashboard,
        tableRows,
        searchQuery,
        monthIndex,
        year,
        recordsPaidFilter,
        errorMessage,
        employeeOptions,
        periodRecords,
        savingRecordId,
        savingEmployeeId,
      ];
}
