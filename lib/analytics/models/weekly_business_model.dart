import '../utils/analytics_money.dart';

class WeeklyBusinessModel {
  final int year;
  final int week;
  final int newCrmClients;
  final int newBillingClients;
  final int billingClientsInvoiced;
  final int invoicesIssued;
  final int invoicesPaid;
  final int invoicesPending;
  final String? amountInvoiced;
  final String? amountReceived;
  final String? amountPending;
  final Map<String, dynamic> raw;

  const WeeklyBusinessModel({
    required this.year,
    required this.week,
    this.newCrmClients = 0,
    this.newBillingClients = 0,
    this.billingClientsInvoiced = 0,
    this.invoicesIssued = 0,
    this.invoicesPaid = 0,
    this.invoicesPending = 0,
    this.amountInvoiced,
    this.amountReceived,
    this.amountPending,
    this.raw = const {},
  });

  factory WeeklyBusinessModel.fromJson(
    Map<String, dynamic> json, {
    required int year,
    required int week,
  }) {
    final data = _unwrap(json);
    final clients = _map(data['clients']);
    final invoices = _map(data['invoices']);
    final amounts = _map(data['amounts']);

    return WeeklyBusinessModel(
      year: _parseInt(data['year']) ?? year,
      week: _parseInt(data['week']) ?? week,
      newCrmClients: _parseInt(clients['new_crm_clients']) ?? 0,
      newBillingClients: _parseInt(clients['new_billing_clients']) ?? 0,
      billingClientsInvoiced:
          _parseInt(clients['billing_clients_invoiced']) ?? 0,
      invoicesIssued:
          _parseInt(invoices['issued'] ?? invoices['invoices_issued']) ?? 0,
      invoicesPaid:
          _parseInt(invoices['paid'] ?? invoices['invoices_paid']) ?? 0,
      invoicesPending:
          _parseInt(invoices['pending'] ?? invoices['invoices_pending']) ?? 0,
      amountInvoiced: _str(amounts['invoiced'] ?? amounts['amount_invoiced']),
      amountReceived: _str(amounts['received'] ?? amounts['amount_received']),
      amountPending: _str(amounts['pending'] ?? amounts['amount_pending']),
      raw: data,
    );
  }

  String formatInvoiced() => AnalyticsMoney.format(amountInvoiced);
  String formatReceived() => AnalyticsMoney.format(amountReceived);
  String formatPending() => AnalyticsMoney.format(amountPending);

  static Map<String, dynamic> _unwrap(Map<String, dynamic> json) {
    final nested = json['data'] ?? json['business'];
    if (nested is Map) return Map<String, dynamic>.from(nested);
    return json;
  }

  static Map<String, dynamic> _map(dynamic v) =>
      v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.round();
    return int.tryParse(v.toString());
  }

  static String? _str(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }
}
