import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/payroll_employee_option.dart';
import '../models/payroll_merged_row.dart';
import '../models/payroll_record_model.dart';
import '../models/payroll_records_paid_filter.dart';
import '../repository/payroll_repository.dart';
import 'payroll_dashboard_event.dart';
import 'payroll_dashboard_state.dart';

List<PayrollEmployeeOption> _employeesFromRecords(List<PayrollRecordModel> records) {
  final byId = <int, PayrollEmployeeOption>{};
  for (final r in records) {
    final id = r.employeeId ?? r.crmUserId;
    if (id == null || id <= 0) continue;
    byId.putIfAbsent(
      id,
      () => PayrollEmployeeOption(
        id: id,
        label: r.employeeName == '—' ? 'Employee #$id' : r.employeeName,
        subtitle: r.mergeEmail,
        profilePhoto: r.profilePhoto,
      ),
    );
  }
  return byId.values.toList();
}

List<PayrollRecordModel> filterPayrollRecordsForPeriod(
  List<PayrollRecordModel> records, {
  required int year,
  required int month,
}) {
  return records.where((r) {
    if (r.year != null && r.month != null) {
      return r.year == year && r.month == month;
    }
    return true;
  }).toList();
}

List<PayrollMergedRow> mergePayrollTableRows({
  required List<PayrollEmployeeOption> employees,
  required List<PayrollRecordModel> records,
  required String searchQuery,
}) {
  final byEmp = <int, PayrollRecordModel>{};
  final byEmail = <String, PayrollRecordModel>{};

  for (final r in records) {
    final ids = <int>{
      ...[
        r.crmUserId,
        r.employeeId,
      ].whereType<int>().where((id) => id > 0),
    };

    if (ids.isEmpty) {
      final n = r.employeeName.trim().toLowerCase();
      if (n.isNotEmpty && n != '—') {
        for (final e in employees) {
          if (e.label.trim().toLowerCase() == n) {
            ids.add(e.id);
            break;
          }
        }
      }
    }

    for (final id in ids) {
      byEmp[id] = r;
    }

    final em = r.mergeEmail;
    if (em != null && em.isNotEmpty) {
      byEmail[em] = r;
    }
  }

  final q = searchQuery.trim().toLowerCase();
  final empList = employees.isNotEmpty ? employees : _employeesFromRecords(records);
  final sorted = [...empList]
    ..sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));

  final rows = <PayrollMergedRow>[];
  for (final emp in sorted) {
    if (q.isNotEmpty) {
      final sub = (emp.subtitle ?? '').toLowerCase();
      if (!emp.label.toLowerCase().contains(q) && !sub.contains(q)) {
        continue;
      }
    }
    PayrollRecordModel? rec = byEmp[emp.id];
    if (rec == null) {
      final sub = emp.subtitle?.trim().toLowerCase();
      if (sub != null && sub.isNotEmpty) {
        rec = byEmail[sub];
      }
    }
    if (rec != null) {
      rows.add(PayrollMergedRow.fromRecord(rec, emp));
    } else {
      rows.add(PayrollMergedRow.placeholder(emp));
    }
  }
  return rows;
}

List<PayrollMergedRow> applyPayrollPaidFilter(
  List<PayrollMergedRow> rows,
  PayrollRecordsPaidFilter filter,
) {
  switch (filter) {
    case PayrollRecordsPaidFilter.all:
      return rows;
    case PayrollRecordsPaidFilter.paid:
      return rows.where((r) => r.paid == true).toList();
    case PayrollRecordsPaidFilter.unpaid:
      return rows.where((r) => r.paid == false).toList();
    case PayrollRecordsPaidFilter.unset:
      return rows.where((r) => r.paid == null).toList();
  }
}

class PayrollDashboardBloc
    extends Bloc<PayrollDashboardEvent, PayrollDashboardState> {
  PayrollDashboardBloc({required PayrollRepository repository})
      : _repository = repository,
        super(PayrollDashboardState.initial()) {
    on<PayrollDashboardStarted>(_onStarted);
    on<PayrollDashboardRefreshed>(_onRefreshed);
    on<PayrollDashboardMonthChanged>(_onMonthChanged);
    on<PayrollDashboardYearChanged>(_onYearChanged);
    on<PayrollDashboardSearchSubmitted>(_onSearch);
    on<PayrollRecordsPaidFilterChanged>(_onPaidFilterChanged);
    on<PayrollInlinePatchRequested>(_onInlinePatch);
    on<PayrollInlineCreateRequested>(_onInlineCreate);
    on<PayrollBulkMarkPaidRequested>(_onBulkMarkPaid);
    on<PayrollBulkUpdateRequested>(_onBulkUpdate);
  }

  final PayrollRepository _repository;
  int _loadSeq = 0;

  Future<List<PayrollEmployeeOption>> _resolveEmployees() async {
    try {
      final fetched = await _repository.fetchEmployeesForPicker();
      if (fetched.isNotEmpty) return fetched;
    } catch (_) {}
    return state.employeeOptions;
  }

  Future<void> _onStarted(
    PayrollDashboardStarted event,
    Emitter<PayrollDashboardState> emit,
  ) =>
      _load(emit);

  Future<void> _onRefreshed(
    PayrollDashboardRefreshed event,
    Emitter<PayrollDashboardState> emit,
  ) =>
      _load(emit);

  Future<void> _onMonthChanged(
    PayrollDashboardMonthChanged event,
    Emitter<PayrollDashboardState> emit,
  ) async {
    final m = event.monthIndex.clamp(1, 12);
    emit(
      state.copyWith(
        monthIndex: m,
        recordsPaidFilter: PayrollRecordsPaidFilter.all,
        searchQuery: '',
        clearError: true,
      ),
    );
    await _load(emit);
  }

  Future<void> _onYearChanged(
    PayrollDashboardYearChanged event,
    Emitter<PayrollDashboardState> emit,
  ) async {
    emit(
      state.copyWith(
        year: event.year,
        recordsPaidFilter: PayrollRecordsPaidFilter.all,
        searchQuery: '',
        clearError: true,
      ),
    );
    await _load(emit);
  }

  Future<void> _onPaidFilterChanged(
    PayrollRecordsPaidFilterChanged event,
    Emitter<PayrollDashboardState> emit,
  ) async {
    if (state.loadStatus == PayrollDashboardLoadStatus.loading) return;
    emit(
      state.copyWith(
        recordsPaidFilter: event.filter,
        tableRows: applyPayrollPaidFilter(state.allTableRows, event.filter),
        clearError: true,
      ),
    );
  }

  Future<void> _onSearch(
    PayrollDashboardSearchSubmitted event,
    Emitter<PayrollDashboardState> emit,
  ) async {
    if (state.loadStatus == PayrollDashboardLoadStatus.loading) return;
    final all = mergePayrollTableRows(
      employees: state.employeeOptions,
      records: state.periodRecords,
      searchQuery: event.query,
    );
    emit(
      state.copyWith(
        searchQuery: event.query,
        clearError: true,
        allTableRows: all,
        tableRows: applyPayrollPaidFilter(all, state.recordsPaidFilter),
      ),
    );
  }

  Future<List<PayrollRecordModel>> _fetchAllRecordsForPeriod(
    int year,
    int month,
    PayrollRecordsPaidFilter paidFilter,
  ) async {
    final out = <PayrollRecordModel>[];
    var page = 1;
    const pageSize = 100;
    while (true) {
      final p = await _repository.loadRecords(
        year: year,
        month: month,
        paidFilter: paidFilter,
        search: null,
        page: page,
        pageSize: pageSize,
      );
      out.addAll(p.results);
      if (p.next == null || p.next!.isEmpty) break;
      page++;
      if (page > 100) break;
    }
    return out;
  }

  Future<void> _load(Emitter<PayrollDashboardState> emit) async {
    final seq = ++_loadSeq;
    final month = state.monthIndex.clamp(1, 12);
    final year = state.year;
    final searchQuery = state.searchQuery;
    final paidFilter = state.recordsPaidFilter;

    emit(
      state.copyWith(
        loadStatus: PayrollDashboardLoadStatus.loading,
        monthIndex: month,
        tableRows: const [],
        allTableRows: const [],
        periodRecords: const [],
        clearError: true,
      ),
    );

    try {
      final dashFuture = _repository.loadDashboard(year: year, month: month);
      final empFuture = _resolveEmployees();
      final recFuture = _fetchAllRecordsForPeriod(
        year,
        month,
        PayrollRecordsPaidFilter.all,
      );

      final dashboard = await dashFuture;
      final employees = await empFuture;
      final rawRecords = await recFuture;

      if (seq != _loadSeq) return;

      final records = filterPayrollRecordsForPeriod(
        rawRecords,
        year: year,
        month: month,
      );

      final allRows = mergePayrollTableRows(
        employees: employees,
        records: records,
        searchQuery: searchQuery,
      );
      final tableRows = applyPayrollPaidFilter(allRows, paidFilter);

      emit(
        state.copyWith(
          loadStatus: PayrollDashboardLoadStatus.success,
          dashboard: dashboard,
          tableRows: tableRows,
          allTableRows: allRows,
          employeeOptions: employees.isNotEmpty
              ? employees
              : state.employeeOptions,
          periodRecords: records,
          clearError: true,
        ),
      );
    } on DioException catch (e) {
      if (seq != _loadSeq) return;
      emit(
        state.copyWith(
          loadStatus: PayrollDashboardLoadStatus.failure,
          errorMessage: _dioMessage(e),
        ),
      );
    } catch (e) {
      if (seq != _loadSeq) return;
      emit(
        state.copyWith(
          loadStatus: PayrollDashboardLoadStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// POST create hit existing (employee, year, month) — treat as update.
  static bool _isUniquePayrollPeriodError(DioException e) {
    if (e.response?.statusCode != 400) return false;
    final msg = _dioMessage(e).toLowerCase();
    return msg.contains('unique') || msg.contains('must make a unique');
  }

  static PayrollRecordModel? _findRecordForCrmUser(
    List<PayrollRecordModel> records,
    int crmUserId,
    List<PayrollEmployeeOption> employees,
  ) {
    PayrollEmployeeOption? opt;
    for (final e in employees) {
      if (e.id == crmUserId) {
        opt = e;
        break;
      }
    }
    final email = opt?.subtitle?.trim().toLowerCase();

    for (final r in records) {
      if (r.id == 0) continue;
      if (r.crmUserId == crmUserId || r.employeeId == crmUserId) {
        return r;
      }
    }
    if (email != null && email.isNotEmpty) {
      for (final r in records) {
        if (r.id != 0 && r.mergeEmail == email) {
          return r;
        }
      }
    }
    return null;
  }

  static String _dioMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final detail = data['detail'];
      if (detail != null) return detail.toString();
      if (data['non_field_errors'] is List) {
        return (data['non_field_errors'] as List).join(', ');
      }
      final fieldParts = <String>[];
      for (final entry in data.entries) {
        final k = entry.key;
        if (k == 'detail' || k == 'non_field_errors') continue;
        final v = entry.value;
        if (v is List) {
          fieldParts.add('$k: ${v.map((x) => x.toString()).join(', ')}');
        } else if (v is Map) {
          fieldParts.add('$k: $v');
        } else if (v != null) {
          fieldParts.add('$k: $v');
        }
      }
      if (fieldParts.isNotEmpty) return fieldParts.join('; ');
    }
    if (data is String && data.isNotEmpty) return data;
    return e.message ?? 'Payroll request failed';
  }

  Future<void> _onInlinePatch(
    PayrollInlinePatchRequested event,
    Emitter<PayrollDashboardState> emit,
  ) async {
    emit(state.copyWith(savingRecordId: event.recordId, clearError: true));
    try {
      await _repository.patchPayrollRecord(
        event.recordId,
        paid: event.paid,
        amountRaw: event.amountRaw,
        notifySalaryCredited: event.notifySalaryCredited,
      );
      await _silentReload(emit);
    } on DioException catch (e) {
      emit(
        state.copyWith(
          errorMessage: _dioMessage(e),
          clearSavingRecordId: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.toString(),
          clearSavingRecordId: true,
        ),
      );
    }
  }

  Future<void> _onInlineCreate(
    PayrollInlineCreateRequested event,
    Emitter<PayrollDashboardState> emit,
  ) async {
    emit(
      state.copyWith(
        savingEmployeeId: event.employeeId,
        clearError: true,
      ),
    );
    final month = state.monthIndex.clamp(1, 12);
    final year = state.year;
    try {
      await _repository.createPayrollRecord(
        employeeId: event.employeeId,
        year: year,
        month: month,
        paid: event.paid,
        amount: event.amountRaw.trim().isEmpty ? null : event.amountRaw.trim(),
        note: null,
        notifySalaryCredited:
            event.paid == true ? event.notifySalaryCredited : null,
      );
      await _silentReload(emit);
    } on DioException catch (e) {
      if (_isUniquePayrollPeriodError(e)) {
        try {
          final records = await _fetchAllRecordsForPeriod(
            year,
            month,
            PayrollRecordsPaidFilter.all,
          );
          final existing = _findRecordForCrmUser(
            records,
            event.employeeId,
            state.employeeOptions,
          );
          if (existing != null) {
            await _repository.patchPayrollRecord(
              existing.id,
              paid: event.paid,
              amountRaw: event.amountRaw,
              notifySalaryCredited: event.paid == true
                  ? event.notifySalaryCredited
                  : null,
            );
            await _silentReload(emit);
            return;
          }
        } catch (_) {}
      }
      emit(
        state.copyWith(
          errorMessage: _dioMessage(e),
          clearSavingEmployeeId: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.toString(),
          clearSavingEmployeeId: true,
        ),
      );
    }
  }

  Future<void> _upsertPayrollRow({
    required PayrollMergedRow row,
    required int year,
    required int month,
    required bool? paid,
    required String amountRaw,
    bool? notifySalaryCredited,
  }) async {
    if (row.recordId != null) {
      await _repository.patchPayrollRecord(
        row.recordId!,
        paid: paid,
        amountRaw: amountRaw,
        notifySalaryCredited:
            paid == true ? notifySalaryCredited : null,
      );
      return;
    }

    try {
      await _repository.createPayrollRecord(
        employeeId: row.employeeId,
        year: year,
        month: month,
        paid: paid,
        amount: amountRaw.trim().isEmpty ? null : amountRaw.trim(),
        note: null,
        notifySalaryCredited:
            paid == true ? notifySalaryCredited : null,
      );
    } on DioException catch (e) {
      if (!_isUniquePayrollPeriodError(e)) rethrow;
      final records = await _fetchAllRecordsForPeriod(
        year,
        month,
        PayrollRecordsPaidFilter.all,
      );
      final existing = _findRecordForCrmUser(
        records,
        row.employeeId,
        state.employeeOptions,
      );
      if (existing == null) rethrow;
      await _repository.patchPayrollRecord(
        existing.id,
        paid: paid,
        amountRaw: amountRaw,
        notifySalaryCredited:
            paid == true ? notifySalaryCredited : null,
      );
    }
  }

  Future<void> _onBulkMarkPaid(
    PayrollBulkMarkPaidRequested event,
    Emitter<PayrollDashboardState> emit,
  ) async {
    await _onBulkUpdate(
      PayrollBulkUpdateRequested(
        employeeIds: event.employeeIds,
        paid: true,
        amountRaw: '',
        notifySalaryCredited: null,
      ),
      emit,
    );
  }

  Future<void> _onBulkUpdate(
    PayrollBulkUpdateRequested event,
    Emitter<PayrollDashboardState> emit,
  ) async {
    if (event.employeeIds.isEmpty) return;
    if (event.paid == null) {
      emit(
        state.copyWith(
          errorMessage: 'Select Paid status before applying bulk update.',
        ),
      );
      return;
    }

    emit(state.copyWith(clearError: true));
    final month = state.monthIndex.clamp(1, 12);
    final year = state.year;
    final useAmount = event.amountOverridesExisting ||
        event.amountRaw.trim().isNotEmpty;

    try {
      for (final employeeId in event.employeeIds.toSet()) {
        PayrollMergedRow? row;
        for (final r in state.allTableRows) {
          if (r.employeeId == employeeId) {
            row = r;
            break;
          }
        }
        if (row == null) continue;

        final amountRaw = useAmount ? event.amountRaw : row.amountRaw;

        emit(state.copyWith(
          savingEmployeeId: employeeId,
          savingRecordId: row.recordId,
        ));

        await _upsertPayrollRow(
          row: row,
          year: year,
          month: month,
          paid: event.paid,
          amountRaw: amountRaw,
          notifySalaryCredited: event.notifySalaryCredited,
        );
      }
      await _silentReload(emit);
    } on DioException catch (e) {
      emit(
        state.copyWith(
          errorMessage: _dioMessage(e),
          clearSavingRecordId: true,
          clearSavingEmployeeId: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.toString(),
          clearSavingRecordId: true,
          clearSavingEmployeeId: true,
        ),
      );
    }
  }

  Future<void> _silentReload(Emitter<PayrollDashboardState> emit) async {
    final seq = ++_loadSeq;
    final month = state.monthIndex.clamp(1, 12);
    final year = state.year;
    final searchQuery = state.searchQuery;
    final paidFilter = state.recordsPaidFilter;
    try {
      final dash = await _repository.loadDashboard(year: year, month: month);
      final employees = await _resolveEmployees();
      final rawRecords = await _fetchAllRecordsForPeriod(
        year,
        month,
        PayrollRecordsPaidFilter.all,
      );
      if (seq != _loadSeq) return;
      final records = filterPayrollRecordsForPeriod(
        rawRecords,
        year: year,
        month: month,
      );
      final allRows = mergePayrollTableRows(
        employees: employees,
        records: records,
        searchQuery: searchQuery,
      );
      final tableRows = applyPayrollPaidFilter(allRows, paidFilter);
      emit(
        state.copyWith(
          loadStatus: PayrollDashboardLoadStatus.success,
          dashboard: dash,
          tableRows: tableRows,
          allTableRows: allRows,
          employeeOptions: employees.isNotEmpty
              ? employees
              : state.employeeOptions,
          periodRecords: records,
          clearSavingRecordId: true,
          clearSavingEmployeeId: true,
        ),
      );
    } catch (_) {
      if (seq != _loadSeq) return;
      emit(
        state.copyWith(
          clearSavingRecordId: true,
          clearSavingEmployeeId: true,
        ),
      );
    }
  }
}
