import 'package:my_app/admin_dashboard/model/client_dashboard_summary_models.dart';

class ClientDashboardSummaryState {
  final bool isLoading;
  final bool isSilentRefreshing;
  final String? error;
  final String? toastError;
  final ClientDashboardSummary summary;
  final int month;
  final int year;
  final int page;
  final int pageSize;
  final String search;
  final TriStateFilter invoiceFilter;
  final TriStateFilter paymentFilter;
  final String? updatingCellKey;
  final String? flashCellKey;

  const ClientDashboardSummaryState({
    this.isLoading = false,
    this.isSilentRefreshing = false,
    this.error,
    this.toastError,
    this.summary = const ClientDashboardSummary(),
    required this.month,
    required this.year,
    this.page = 1,
    this.pageSize = 20,
    this.search = '',
    this.invoiceFilter = TriStateFilter.all,
    this.paymentFilter = TriStateFilter.all,
    this.updatingCellKey,
    this.flashCellKey,
  });

  factory ClientDashboardSummaryState.initial() {
    final now = DateTime.now();
    return ClientDashboardSummaryState(month: now.month, year: now.year);
  }

  ClientDashboardSummaryState copyWith({
    bool? isLoading,
    bool? isSilentRefreshing,
    String? error,
    String? toastError,
    bool clearToastError = false,
    ClientDashboardSummary? summary,
    int? month,
    int? year,
    int? page,
    int? pageSize,
    String? search,
    TriStateFilter? invoiceFilter,
    TriStateFilter? paymentFilter,
    String? updatingCellKey,
    bool clearUpdatingCell = false,
    String? flashCellKey,
    bool clearFlashCell = false,
  }) {
    return ClientDashboardSummaryState(
      isLoading: isLoading ?? this.isLoading,
      isSilentRefreshing: isSilentRefreshing ?? this.isSilentRefreshing,
      error: error,
      toastError: clearToastError ? null : (toastError ?? this.toastError),
      summary: summary ?? this.summary,
      month: month ?? this.month,
      year: year ?? this.year,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      search: search ?? this.search,
      invoiceFilter: invoiceFilter ?? this.invoiceFilter,
      paymentFilter: paymentFilter ?? this.paymentFilter,
      updatingCellKey:
          clearUpdatingCell ? null : (updatingCellKey ?? this.updatingCellKey),
      flashCellKey: clearFlashCell ? null : (flashCellKey ?? this.flashCellKey),
    );
  }
}
