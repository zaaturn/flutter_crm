class InvoiceItemModel {
  String name;


  String hsnSacCode;

  double quantity;
  double unitPrice;
  double taxRate;
  String currency;

  InvoiceItemModel({
    required this.name,
    required this.hsnSacCode,
    required this.quantity,
    required this.unitPrice,
    required this.taxRate,
    this.currency = "₹",
  });


  double get total => quantity * unitPrice;

  factory InvoiceItemModel.empty() {
    return InvoiceItemModel(
      name: "",
      hsnSacCode: "", // optional
      quantity: 1.0,
      unitPrice: 0.0,
      taxRate: 18.0,
      currency: "₹",
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      name: json["name"]?.toString() ?? "",
      hsnSacCode: json["hsn_sac_code"]?.toString() ?? "",
      quantity: _toDouble(json["quantity"]),
      unitPrice: _toDouble(json["unit_price"]),
      taxRate: _toDouble(json["tax_rate"]),
      currency: json["currency"]?.toString() ?? "₹",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,


      "hsn_sac_code": hsnSacCode.isEmpty ? null : hsnSacCode,

      "quantity": quantity,
      "unit_price": unitPrice,
      "tax_rate": taxRate,
      "currency": currency,
      "line_total": total,
    };
  }
}

