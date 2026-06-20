class MonthlyBillingMonth {
  final int month;
  final String monthLabel;
  final String period;
  final int clientsInvoiced;
  final int newCrmClients;
  final int invoicesIssued;
  final int invoicesPaid;
  final int invoicesPending;
  final String? amountInvoiced;
  final String? amountReceived;
  final String? amountPending;

  const MonthlyBillingMonth({
    required this.month,
    required this.monthLabel,
    required this.period,
    this.clientsInvoiced = 0,
    this.newCrmClients = 0,
    this.invoicesIssued = 0,
    this.invoicesPaid = 0,
    this.invoicesPending = 0,
    this.amountInvoiced,
    this.amountReceived,
    this.amountPending,
  });

  factory MonthlyBillingMonth.fromJson(Map<String, dynamic> json) {
    return MonthlyBillingMonth(
      month: _int(json['month']),
      monthLabel: (json['month_label'] ?? '').toString(),
      period: (json['period'] ?? '').toString(),
      clientsInvoiced: _int(json['clients_invoiced']),
      newCrmClients: _int(json['new_crm_clients']),
      invoicesIssued: _int(json['invoices_issued']),
      invoicesPaid: _int(json['invoices_paid']),
      invoicesPending: _int(json['invoices_pending']),
      amountInvoiced: _str(json['amount_invoiced']),
      amountReceived: _str(json['amount_received']),
      amountPending: _str(json['amount_pending']),
    );
  }

  static int _int(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static String? _str(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }
}

class MonthlyBillingTotals {
  final int invoicesIssued;
  final int invoicesPaid;
  final String? amountInvoiced;
  final String? amountReceived;
  final String? amountPending;

  const MonthlyBillingTotals({
    this.invoicesIssued = 0,
    this.invoicesPaid = 0,
    this.amountInvoiced,
    this.amountReceived,
    this.amountPending,
  });

  factory MonthlyBillingTotals.fromJson(Map<String, dynamic> json) {
    return MonthlyBillingTotals(
      invoicesIssued: _int(json['invoices_issued']),
      invoicesPaid: _int(json['invoices_paid']),
      amountInvoiced: _str(json['amount_invoiced']),
      amountReceived: _str(json['amount_received']),
      amountPending: _str(json['amount_pending']),
    );
  }

  static int _int(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static String? _str(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }
}

class MonthlyBillingModel {
  final int year;
  final List<MonthlyBillingMonth> months;
  final MonthlyBillingTotals totals;

  const MonthlyBillingModel({
    required this.year,
    this.months = const [],
    this.totals = const MonthlyBillingTotals(),
  });

  factory MonthlyBillingModel.fromJson(
    Map<String, dynamic> json, {
    required int year,
  }) {
    final data = _unwrap(json);
    final monthsList = data['months'];
    final months = monthsList is List
        ? monthsList
            .whereType<Map>()
            .map((e) => MonthlyBillingMonth.fromJson(
                  Map<String, dynamic>.from(e),
                ))
            .toList()
        : <MonthlyBillingMonth>[];

    final totalsRaw = data['totals'];
    final totals = totalsRaw is Map
        ? MonthlyBillingTotals.fromJson(Map<String, dynamic>.from(totalsRaw))
        : const MonthlyBillingTotals();

    return MonthlyBillingModel(
      year: _int(data['year']) ?? year,
      months: months,
      totals: totals,
    );
  }

  static Map<String, dynamic> _unwrap(Map<String, dynamic> json) {
    final nested = json['data'] ?? json['billing'];
    if (nested is Map) return Map<String, dynamic>.from(nested);
    return json;
  }

  static int? _int(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}
