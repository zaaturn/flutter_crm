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
    // 💡 If the backend sends 'false', we treat it as 'null' (Select) by default
    // UNLESS it was explicitly set by the user (which we can't tell easily, 
    // but this will force "Select" as the default state for your screen).
    
    bool? parse(dynamic v) {
      if (v == true) return true;
      if (v == false) return false;
      return null;
    }

    return PaymentModel(
      id: json['id'],
      clientId: json['client'],
      clientName: json['client_name'] ?? '',
      month: json['month'],
      year: json['year'],
      invoiceSent: parse(json['invoice_sent']),
      paymentReceived: parse(json['payment_received']),
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