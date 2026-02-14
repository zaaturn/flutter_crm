import 'invoice_item_model.dart';

class InvoiceModel {
  final String id;
  final String? number;
  final String status;

  final double subtotal;
  final double taxTotal;
  final double grandTotal;


  final Map<String, double> taxBreakup;

  final String? pdfUrl;
  final List<InvoiceItemModel> items;

  final String companyName;
  final String companyAddress;

  final String clientName;
  final String clientAddress;

  final String dateString;

  InvoiceModel({
    required this.id,
    this.number,
    required this.status,
    required this.subtotal,
    required this.taxTotal,
    required this.grandTotal,
    required this.taxBreakup,
    this.pdfUrl,
    required this.items,
    required this.companyName,
    required this.companyAddress,
    required this.clientName,
    required this.clientAddress,
    required this.dateString,
  });

  double get total => grandTotal;
  String get invoiceDate => dateString;

  Map<String, dynamic> get clientManual => {
    "name": clientName,
    "address": {"full_address": clientAddress},
  };


  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json["id"]?.toString() ?? "",

      number: json["invoice_number"]?.toString(),

      status: json["status"] ?? "DRAFT",


      subtotal: _toDouble(json["subtotal"]),
      taxTotal: _toDouble(json["tax_total"]),
      grandTotal: _toDouble(json["grand_total"]),


      taxBreakup: (json["tax_breakup"] as Map<String, dynamic>? ?? {})
          .map((key, value) => MapEntry(
        key,
        _toDouble(value),
      )),

      pdfUrl: json["pdf_url"],

      items: (json["items"] as List? ?? [])
          .map((e) => InvoiceItemModel.fromJson(e))
          .toList(),

      companyName: json["company"]?["name"] ?? "",

      companyAddress:
      json["company"]?["address"]?["full_address"] ?? "",

      clientName:
      json["client"]?["name"] ??
          json["client_name"] ??
          "Client",

      clientAddress:
      json["client"]?["address"]?["full_address"] ?? "",

      dateString:
      json["invoice_date"] ??
          json["created_at"] ??
          "N/A",
    );
  }
}

