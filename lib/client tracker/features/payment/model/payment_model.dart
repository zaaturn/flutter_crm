class PaymentModel {
  final int id;
  final int clientId;
  final String clientName;
  final int month;
  final int year;
  bool invoiceSent;
  bool paymentReceived;

  PaymentModel({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.month,
    required this.year,
    required this.invoiceSent,
    required this.paymentReceived,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
    id: json['id'],
    clientId: json['client'],
    clientName: json['client_name'] ?? '',
    month: json['month'],
    year: json['year'],
    invoiceSent: json['invoice_sent'] ?? false,
    paymentReceived: json['payment_received'] ?? false,
  );
}

const List<String> monthNames = [
  '', 'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];