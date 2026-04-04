import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/payroll_employee_option.dart';
import '../models/payroll_merged_row.dart';
import '../models/payroll_record_model.dart';
import '../repository/payroll_repository.dart';
import 'payroll_dashboard_event.dart';
import 'payroll_dashboard_state.dart';

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
  final sorted = [...employees]
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
    on<PayrollInlinePatchRequested>(_onInlinePatch);
    on<PayrollInlineCreateRequested>(_onInlineCreate);
  }

  final PayrollRepository _repository;

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
    emit(state.copyWith(monthIndex: m, clearError: true));
    await _load(emit);
  }

  Future<void> _onYearChanged(
    PayrollDashboardYearChanged event,
    Emitter<PayrollDashboardState> emit,
  ) async {
    emit(state.copyWith(year: event.year, clearError: true));
    await _load(emit);
  }

  Future<void> _onSearch(
    PayrollDashboardSearchSubmitted event,
    Emitter<PayrollDashboardState> emit,
  ) async {
    emit(
      state.copyWith(
        searchQuery: event.query,
        clearError: true,
        tableRows: mergePayrollTableRows(
          employees: state.employeeOptions,
          records: state.periodRecords,
          searchQuery: event.query,
        ),
      ),
    );
  }

  Future<List<PayrollRecordModel>> _fetchAllRecordsForPeriod(
    int year,
    int month,
  ) async {
    final out = <PayrollRecordModel>[];
    var page = 1;
    const pageSize = 100;
    while (true) {
      final p = await _repository.loadRecords(
        year: year,
        month: month,
        status: null,
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
    final month = state.monthIndex.clamp(1, 12);
    final year = state.year;

    emit(
      state.copyWith(
        loadStatus: PayrollDashboardLoadStatus.loading,
        monthIndex: month,
        clearError: true,
      ),
    );

    try {
      final dashFuture = _repository.loadDashboard(year: year, month: month);
      final empFuture = _repository.fetchEmployeesForPicker();
      final recFuture = _fetchAllRecordsForPeriod(year, month);

      final dashboard = await dashFuture;
      var employees = state.employeeOptions;
      try {
        employees = await empFuture;
      } catch (_) {}
      final records = await recFuture;

      final tableRows = mergePayrollTableRows(
        employees: employees,
        records: records,
        searchQuery: state.searchQuery,
      );

      emit(
        state.copyWith(
          loadStatus: PayrollDashboardLoadStatus.success,
          dashboard: dashboard,
          tableRows: tableRows,
          employeeOptions: employees,
          periodRecords: records,
          clearError: true,
        ),
      );
    } on DioException catch (e) {
      emit(
        state.copyWith(
          loadStatus: PayrollDashboardLoadStatus.failure,
          errorMessage: _dioMessage(e),
        ),
      );
    } catch (e) {
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
      );
      await _silentReload(emit);
    } on DioException catch (e) {
      if (_isUniquePayrollPeriodError(e)) {
        try {
          final records = await _fetchAllRecordsForPeriod(year, month);
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

  Future<void> _silentReload(Emitter<PayrollDashboardState> emit) async {
    final month = state.monthIndex.clamp(1, 12);
    final year = state.year;
    try {
      final dash = await _repository.loadDashboard(year: year, month: month);
      final records = await _fetchAllRecordsForPeriod(year, month);
      final tableRows = mergePayrollTableRows(
        employees: state.employeeOptions,
        records: records,
        searchQuery: state.searchQuery,
      );
      emit(
        state.copyWith(
          loadStatus: PayrollDashboardLoadStatus.success,
          dashboard: dash,
          tableRows: tableRows,
          periodRecords: records,
          clearSavingRecordId: true,
          clearSavingEmployeeId: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          clearSavingRecordId: true,
          clearSavingEmployeeId: true,
        ),
      );
    }
  }
}
