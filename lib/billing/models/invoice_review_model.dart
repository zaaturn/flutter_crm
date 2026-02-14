class InvoiceReviewModel {
  final String id;
  final String invoiceNumber;
  final String status;
  final DateTime invoiceDate;
  final BillingFrom billingFrom;
  final BillingTo billingTo;
  final List<InvoiceItem> items;
  final double subtotal;
  final double taxTotal;
  final double grandTotal;

  InvoiceReviewModel({
    required this.id,
    required this.invoiceNumber,
    required this.status,
    required this.invoiceDate,
    required this.billingFrom,
    required this.billingTo,
    required this.items,
    required this.subtotal,
    required this.taxTotal,
    required this.grandTotal,
  });

  factory InvoiceReviewModel.fromJson(Map<String, dynamic> json) {
    return InvoiceReviewModel(
      id: json['id'].toString(),
      invoiceNumber: json['invoice_number'].toString(),
      status: json['status'],
      invoiceDate: DateTime.parse(json['invoice_date']),
      billingFrom: BillingFrom.fromJson(
        json['billing_from'] as Map<String, dynamic>,
      ),
      billingTo: BillingTo.fromJson(
        json['billing_to'] as Map<String, dynamic>,
      ),
      items: (json['items'] as List)
          .map((e) => InvoiceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: _toDouble(json['subtotal']),
      taxTotal: _toDouble(json['tax_total']),
      grandTotal: _toDouble(json['grand_total']),
    );
  }
}

/* ============================================================
 * BILLING FROM
 * ============================================================ */

class BillingFrom {
  final String name;
  final String gstNumber;
  final String address;
  final String? email;
  final String? phone;

  BillingFrom({
    required this.name,
    required this.gstNumber,
    required this.address,
    this.email,
    this.phone,
  });

  factory BillingFrom.fromJson(Map<String, dynamic> json) {
    return BillingFrom(
      name: json['name'].toString(),
      gstNumber: json['gst_number'].toString(),
      address: json['address']?.toString() ?? '',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
    );
  }
}

/* ============================================================
 * BILLING TO
 * ============================================================ */

class BillingTo {
  final String name;
  final String? gstin;
  final String? address;

  BillingTo({
    required this.name,
    this.gstin,
    this.address,
  });

  factory BillingTo.fromJson(Map<String, dynamic> json) {
    return BillingTo(
      name: json['name'].toString(),
      gstin: json['gstin']?.toString(),
      address: json['address']?.toString(),
    );
  }
}

/* ============================================================
 * INVOICE ITEM
 * ============================================================ */

class InvoiceItem {
  final String description;
  final double quantity;
  final double price;
  final double? taxRate;
  final double? lineTotal;
  final String? hsnSacCode;

  InvoiceItem({
    required this.description,
    required this.quantity,
    required this.price,
    this.taxRate,
    this.lineTotal,
    this.hsnSacCode,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      description: json['description'].toString(),
      quantity: _toDouble(json['quantity']),
      price: _toDouble(json['price']),
      taxRate: json.containsKey('tax_rate')
          ? _toNullableDouble(json['tax_rate'])
          : null,
      lineTotal: json.containsKey('line_total')
          ? _toNullableDouble(json['line_total'])
          : null,
      hsnSacCode: json['hsn_sac_code']?.toString(),
    );
  }
}

/* ============================================================
 * HELPERS (SAFE DECIMAL PARSING)
 * ============================================================ */

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? 0.0;
}

double? _toNullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}
