import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/admin_dashboard/cubit/client_dashboard_summary_state.dart';
import 'package:my_app/admin_dashboard/model/client_dashboard_summary_models.dart';
import 'package:my_app/admin_dashboard/repository/client_dashboard_summary_repository.dart';
import 'package:my_app/client tracker/core/network/api_services.dart';

class ClientDashboardSummaryCubit extends Cubit<ClientDashboardSummaryState> {
  ClientDashboardSummaryCubit(this._repository)
      : super(ClientDashboardSummaryState.initial());

  final ClientDashboardSummaryRepository _repository;
  Timer? _searchDebounce;
  Timer? _pollTimer;
  Timer? _flashTimer;

  void initialize() {
    load(showLoading: true);
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      silentRefresh();
    });
  }

  void _safeEmit(ClientDashboardSummaryState next) {
    if (!isClosed) emit(next);
  }

  Future<void> load({bool showLoading = true}) async {
    if (showLoading) {
      _safeEmit(state.copyWith(isLoading: true, error: null));
    }
    try {
      final summary = await _repository.fetchSummary(
        month: state.month,
        year: state.year,
        page: state.page,
        pageSize: state.pageSize,
        search: state.search,
        invoiceFilter: state.invoiceFilter,
        paymentFilter: state.paymentFilter,
      );
      if (isClosed) return;
      _safeEmit(state.copyWith(isLoading: false, summary: summary, error: null));
    } catch (e) {
      if (isClosed) return;
      _safeEmit(state.copyWith(
        isLoading: false,
        error: e is ApiException ? e.message : e.toString(),
      ));
    }
  }

  Future<void> silentRefresh() async {
    if (isClosed || state.isLoading || state.updatingCellKey != null) return;
    _safeEmit(state.copyWith(isSilentRefreshing: true));
    try {
      final summary = await _repository.fetchSummary(
        month: state.month,
        year: state.year,
        page: state.page,
        pageSize: state.pageSize,
        search: state.search,
        invoiceFilter: state.invoiceFilter,
        paymentFilter: state.paymentFilter,
      );
      if (isClosed) return;
      if (summary.fingerprint() != state.summary.fingerprint()) {
        _safeEmit(state.copyWith(summary: summary, isSilentRefreshing: false));
      } else {
        _safeEmit(state.copyWith(isSilentRefreshing: false));
      }
    } catch (_) {
      if (isClosed) return;
      _safeEmit(state.copyWith(isSilentRefreshing: false));
    }
  }

  void setMonth(int month) {
    if (month == state.month) return;
    _safeEmit(state.copyWith(month: month, page: 1));
    load();
  }

  void setYear(int year) {
    if (year == state.year) return;
    _safeEmit(state.copyWith(year: year, page: 1));
    load();
  }

  void setSearch(String value) {
    _safeEmit(state.copyWith(search: value, page: 1));
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!isClosed) load();
    });
  }

  void setInvoiceFilter(TriStateFilter filter) {
    if (filter == state.invoiceFilter) return;
    _safeEmit(state.copyWith(invoiceFilter: filter, page: 1));
    load();
  }

  void setPaymentFilter(TriStateFilter filter) {
    if (filter == state.paymentFilter) return;
    _safeEmit(state.copyWith(paymentFilter: filter, page: 1));
    load();
  }

  void setPage(int page) {
    if (page == state.page) return;
    _safeEmit(state.copyWith(page: page));
    load();
  }

  void setPageSize(int pageSize) {
    if (pageSize == state.pageSize) return;
    _safeEmit(state.copyWith(pageSize: pageSize, page: 1));
    load();
  }

  Future<void> toggleInvoice(ClientSummaryRow row) async {
    final cellKey = '${row.paymentRecordId}_invoice';
    final oldValue = row.invoiceSent;
    final newValue = cycleTriState(oldValue);

    _safeEmit(state.copyWith(
      updatingCellKey: cellKey,
      clearToastError: true,
      summary: _patchSummary(
        rowId: row.paymentRecordId,
        invoiceSent: newValue,
        invoiceDelta: _invoiceDelta(oldValue, newValue),
      ),
    ));

    try {
      final updated = await _repository.patchInvoiceSent(
        paymentRecordId: row.paymentRecordId,
        invoiceSent: newValue,
      );
      if (isClosed) return;
      _safeEmit(state.copyWith(
        clearUpdatingCell: true,
        flashCellKey: cellKey,
        summary: _replaceRow(updated),
      ));
      _scheduleFlashClear();
    } catch (e) {
      if (isClosed) return;
      _safeEmit(state.copyWith(
        clearUpdatingCell: true,
        toastError: e is ApiException ? e.message : 'Update failed',
        summary: _patchSummary(
          rowId: row.paymentRecordId,
          invoiceSent: oldValue,
          invoiceDelta: _invoiceDelta(newValue, oldValue),
        ),
      ));
    }
  }

  Future<void> togglePayment(ClientSummaryRow row) async {
    final cellKey = '${row.paymentRecordId}_payment';
    final oldValue = row.paymentReceived;
    final newValue = cycleTriState(oldValue);

    _safeEmit(state.copyWith(
      updatingCellKey: cellKey,
      clearToastError: true,
      summary: _patchSummary(
        rowId: row.paymentRecordId,
        paymentReceived: newValue,
        paymentDelta: _paymentDelta(oldValue, newValue),
      ),
    ));

    try {
      final updated = await _repository.patchPaymentReceived(
        paymentRecordId: row.paymentRecordId,
        paymentReceived: newValue,
      );
      if (isClosed) return;
      _safeEmit(state.copyWith(
        clearUpdatingCell: true,
        flashCellKey: cellKey,
        summary: _replaceRow(updated),
      ));
      _scheduleFlashClear();
    } catch (e) {
      if (isClosed) return;
      _safeEmit(state.copyWith(
        clearUpdatingCell: true,
        toastError: e is ApiException ? e.message : 'Update failed',
        summary: _patchSummary(
          rowId: row.paymentRecordId,
          paymentReceived: oldValue,
          paymentDelta: _paymentDelta(newValue, oldValue),
        ),
      ));
    }
  }

  void _scheduleFlashClear() {
    _flashTimer?.cancel();
    _flashTimer = Timer(const Duration(milliseconds: 700), () {
      _safeEmit(state.copyWith(clearFlashCell: true));
    });
  }

  ClientDashboardSummary _patchSummary({
    required int rowId,
    bool? invoiceSent,
    bool? paymentReceived,
    _CountDelta invoiceDelta = const _CountDelta(),
    _CountDelta paymentDelta = const _CountDelta(),
  }) {
    final rows = state.summary.results.map((row) {
      if (row.paymentRecordId != rowId) return row;
      return row.copyWith(
        invoiceSent: invoiceSent ?? row.invoiceSent,
        paymentReceived: paymentReceived ?? row.paymentReceived,
        updatedAt: DateTime.now(),
      );
    }).toList();

    return state.summary.copyWith(
      results: rows,
      invoicesSentCount:
          state.summary.invoicesSentCount + invoiceDelta.sent,
      invoicesPendingCount:
          state.summary.invoicesPendingCount + invoiceDelta.pending,
      paymentsReceivedCount:
          state.summary.paymentsReceivedCount + paymentDelta.sent,
      paymentsPendingCount:
          state.summary.paymentsPendingCount + paymentDelta.pending,
    );
  }

  ClientDashboardSummary _replaceRow(ClientSummaryRow updated) {
    final List<ClientSummaryRow> rows = state.summary.results.map((row) {
      if (row.paymentRecordId != updated.paymentRecordId) return row;
      return row.copyWith(
        invoiceSent: updated.invoiceSent,
        paymentReceived: updated.paymentReceived,
        updatedAt: updated.updatedAt,
        clientName:
            updated.clientName.isNotEmpty ? updated.clientName : row.clientName,
        email: updated.email.isNotEmpty ? updated.email : row.email,
      );
    }).toList();
    return state.summary.copyWith(results: rows);
  }

  _CountDelta _invoiceDelta(bool? from, bool? to) {
    return _CountDelta(
      sent: _sentDelta(from, to),
      pending: _pendingDelta(from, to),
    );
  }

  _CountDelta _paymentDelta(bool? from, bool? to) {
    return _CountDelta(
      sent: _sentDelta(from, to),
      pending: _pendingDelta(from, to),
    );
  }

  int _sentDelta(bool? from, bool? to) {
    var delta = 0;
    if (from == true) delta--;
    if (to == true) delta++;
    return delta;
  }

  int _pendingDelta(bool? from, bool? to) {
    var delta = 0;
    if (from == null) delta--;
    if (to == null) delta++;
    return delta;
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    _pollTimer?.cancel();
    _flashTimer?.cancel();
    return super.close();
  }
}

class _CountDelta {
  final int sent;
  final int pending;

  const _CountDelta({this.sent = 0, this.pending = 0});
}
