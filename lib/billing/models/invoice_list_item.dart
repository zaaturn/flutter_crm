class InvoiceListItem {
  final String id;
  final String invoiceNumber;
  final String clientName;
  final DateTime? dateIssued;
  final double amount;
  final bool isIssued;
  final bool hasPdf;
  final String paymentStatus;

  const InvoiceListItem({
    required this.id,
    required this.invoiceNumber,
    required this.clientName,
    required this.dateIssued,
    required this.amount,
    required this.isIssued,
    required this.hasPdf,
    required this.paymentStatus,
  });

  static bool _toBool(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final s = v.trim().toLowerCase();
      return s == '1' || s == 'true' || s == 'yes';
    }
    return false;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static DateTime? _tryParseDate(dynamic raw) {
    final s = raw?.toString();
    if (s == null || s.isEmpty) return null;
    try {
      return DateTime.parse(s);
    } catch (_) {
      return null;
    }
  }

  factory InvoiceListItem.fromJson(Map<String, dynamic> json) {
    final invoiceNumber = (json['invoice_number'] ?? json['number'] ?? '').toString();
    final clientName =
        (json['client_name'] ?? json['client']?['name'] ?? json['client'] ?? 'Client')
            .toString();
    final dateIssued = _tryParseDate(json['invoice_date'] ?? json['issued_at'] ?? json['created_at']);
    final amount = _toDouble(json['grand_total'] ?? json['total'] ?? json['amount']);

    return InvoiceListItem(
      id: (json['id'] ?? '').toString(),
      invoiceNumber: invoiceNumber.isEmpty ? '-' : invoiceNumber,
      clientName: clientName.isEmpty ? 'Client' : clientName,
      dateIssued: dateIssued,
      amount: amount,
      isIssued: _toBool(json['is_issued'] ?? json['issued'] ?? (json['status'] == 'ISSUED')),
      hasPdf: _toBool(json['has_pdf'] ?? (json['pdf_url'] != null)),
      paymentStatus: (json['payment_status'] ?? json['payment'] ?? 'UNPAID').toString(),
    );
  }
}

