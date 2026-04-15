import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../services/api_client.dart';
import '../models/invoice_list_item.dart';

class BillingDioApi {
  BillingDioApi._();

  static final Dio _dio = ApiClient().dio;

  static String get _billingBase => '/api/billing';

  static Future<List<InvoiceListItem>> listInvoicesByMonth({
    required String month, // yyyy-MM
  }) async {
    final res = await _dio.get<List<dynamic>>(
      '$_billingBase/invoices/list/',
      queryParameters: {'month': month},
    );

    final data = res.data ?? const [];
    return data
        .whereType<Map>()
        .map((e) => InvoiceListItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<void> issueInvoice({
    required String invoiceId,
    String? pdfDesign,
  }) async {
    await _dio.post(
      '$_billingBase/invoices/$invoiceId/issue/',
      data: pdfDesign == null ? <String, dynamic>{} : {'pdf_design': pdfDesign},
    );
  }

  static Future<void> updatePaymentStatus({
    required String invoiceId,
    required String paymentStatus,
  }) async {
    // Backend expected: PATCH /api/billing/invoices/<id>/payment/ {payment_status: "..."}
    await _dio.patch(
      '$_billingBase/invoices/$invoiceId/payment/',
      data: {'payment_status': paymentStatus},
    );
  }

  static Future<Uint8List> downloadInvoicePdfBytes({
    required String invoiceId,
  }) async {
    final res = await _dio.get<List<int>>(
      '$_billingBase/invoices/$invoiceId/download/',
      options: Options(
        responseType: ResponseType.bytes,
        headers: {'Accept': 'application/pdf'},
      ),
    );

    final bytes = Uint8List.fromList(res.data ?? const <int>[]);
    return bytes;
  }

  static Future<Map<String, dynamic>> getInvoiceDraft({
    required String invoiceId,
  }) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '$_billingBase/invoices/$invoiceId/',
    );
    return res.data ?? <String, dynamic>{};
  }

  static Future<void> updateInvoiceDraft({
    required String invoiceId,
    required Map<String, dynamic> body,
  }) async {
    await _dio.patch(
      '$_billingBase/invoices/$invoiceId/draft/',
      data: body,
    );
  }
}

