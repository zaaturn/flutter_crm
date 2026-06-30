import 'package:my_app/admin_dashboard/model/client_dashboard_summary_models.dart';
import 'package:my_app/client tracker/core/constants/app_constant.dart';
import 'package:my_app/client tracker/core/network/api_services.dart';

class ClientDashboardSummaryRepository {
  final ApiClient _api = ApiClient();

  Future<ClientDashboardSummary> fetchSummary({
    required int month,
    required int year,
    int page = 1,
    int pageSize = 20,
    String search = '',
    TriStateFilter invoiceFilter = TriStateFilter.all,
    TriStateFilter paymentFilter = TriStateFilter.all,
  }) async {
    final params = <String, String>{
      'month': month.toString(),
      'year': year.toString(),
      'page': page.toString(),
      'page_size': pageSize.toString(),
    };

    if (search.trim().isNotEmpty) {
      params['search'] = search.trim();
    }
    _appendTriState(params, 'invoice_sent', invoiceFilter);
    _appendTriState(params, 'payment_received', paymentFilter);

    final data = await _api.get(
      AppConstants.dashboardSummary,
      queryParams: params,
    );

    if (data is Map<String, dynamic>) {
      return ClientDashboardSummary.fromJson(data);
    }
    if (data is Map) {
      return ClientDashboardSummary.fromJson(Map<String, dynamic>.from(data));
    }
    return const ClientDashboardSummary();
  }

  Future<ClientSummaryRow> patchInvoiceSent({
    required int paymentRecordId,
    required bool? invoiceSent,
  }) async {
    final data = await _api.patch(
      AppConstants.paymentById(paymentRecordId),
      {'invoice_sent': invoiceSent},
    );
    return ClientSummaryRow.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<ClientSummaryRow> patchPaymentReceived({
    required int paymentRecordId,
    required bool? paymentReceived,
  }) async {
    final data = await _api.patch(
      AppConstants.paymentById(paymentRecordId),
      {'payment_received': paymentReceived},
    );
    return ClientSummaryRow.fromJson(Map<String, dynamic>.from(data as Map));
  }

  void _appendTriState(
    Map<String, String> params,
    String key,
    TriStateFilter filter,
  ) {
    switch (filter) {
      case TriStateFilter.all:
        return;
      case TriStateFilter.yes:
        params[key] = 'true';
      case TriStateFilter.no:
        params[key] = 'false';
      case TriStateFilter.pending:
        params[key] = 'null';
    }
  }
}
