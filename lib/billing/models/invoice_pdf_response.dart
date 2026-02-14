class InvoicePdfResponse {
  final String pdfUrl;
  final String status;
  final String invoiceNumber;

  InvoicePdfResponse({
    required this.pdfUrl,
    required this.status,
    required this.invoiceNumber,
  });

  factory InvoicePdfResponse.fromJson(Map<String, dynamic> json) {
    return InvoicePdfResponse(
      pdfUrl: json['pdf_url'],
      status: json['status'],
      invoiceNumber: json['invoice_number'],
    );
  }
}
