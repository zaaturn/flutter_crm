class PaymentModel {
  final int id;
  final int clientId;
  final String clientName;
  final int month;
  final int year;

  final bool? invoiceSent;
  final bool? paymentReceived;
  final DateTime updatedAt;

  PaymentModel({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.month,
    required this.year,
    required this.invoiceSent,
    required this.paymentReceived,
    required this.updatedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      clientId: json['client'],
      clientName: json['client_name'] ?? '',
      month: json['month'],
      year: json['year'],

      // ✅ DO NOT default to false anymore
      invoiceSent: json['invoice_sent'],
      paymentReceived: json['payment_received'],

      // ✅ parse updated_at
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client': clientId,
      'month': month,
      'year': year,
      'invoice_sent': invoiceSent,
      'payment_received': paymentReceived,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

const List<String> monthNames = [
  '', 'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];