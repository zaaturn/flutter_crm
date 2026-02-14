import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../models/company_model.dart';
import '../models/CompanyBankDetailsModel.dart';
import '../models/invoice_model.dart';
import '../models/invoice_review_model.dart';
import '../models/invoice_pdf_response.dart';

/* ================= EXCEPTIONS ================= */

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class UnauthorizedException extends ApiException {
  UnauthorizedException() : super("Unauthorized");
}

class ValidationException extends ApiException {
  ValidationException(String message) : super(message);
}

class ServerException extends ApiException {
  ServerException() : super("Server error");
}

class NetworkException extends ApiException {
  NetworkException() : super("Network error");
}

/* ================= BILLING API ================= */

class BillingApi {
  // 🌍 UNIVERSAL BASE URL
  static const String _base =
  String.fromEnvironment('BASE_URL', defaultValue: 'http://localhost:8000');

  static String get baseUrl => "$_base/api/billing";

  /* ================= HEADERS ================= */

  static Map<String, String> _headers(String token) => {
    "Authorization": "Bearer $token",
    "Accept": "application/json",
  };

  /* ================= RESPONSE HANDLER ================= */

  static dynamic _handleResponse(
      http.Response response, {
        bool allowUnauthorized = false,
      }) {
    switch (response.statusCode) {
      case 200:
      case 201:
        if (response.body.isEmpty) return null;
        return jsonDecode(response.body);

      case 400:
        throw ValidationException(response.body);

      case 401:
        if (allowUnauthorized) {
          throw ApiException("Unauthorized for this action");
        }
        throw UnauthorizedException();

      case 404:
        return null;

      case 500:
        throw ServerException();

      default:
        throw ApiException("Error ${response.statusCode}");
    }
  }

  /* ================= COMPANY ================= */

  static Future<CompanyModel?> getCompanyProfile(String token) async {
    final res = await http.get(
      Uri.parse("$baseUrl/companies/me/"),
      headers: _headers(token),
    );

    final data = _handleResponse(res);
    return data == null ? null : CompanyModel.fromJson(data);
  }

  static Future<List<CompanyModel>> getCompanies(String token) async {
    final res = await http.get(
      Uri.parse("$baseUrl/companies/dropdown/"),
      headers: _headers(token),
    );

    final data = _handleResponse(res);
    if (data is List) {
      return data.map((e) => CompanyModel.fromJson(e)).toList();
    }
    return [];
  }

  static Future<CompanyModel> createOrUpdateCompany(
      String token,
      Map<String, dynamic> body, {
        String? logoPath,
        String? signaturePath,
      }) async {
    final uri = Uri.parse("$baseUrl/companies/");
    final request = http.MultipartRequest("POST", uri)
      ..headers.addAll(_headers(token));

    body.forEach((key, value) {
      if (value == null) return;
      request.fields[key] =
      value is Map ? jsonEncode(value) : value.toString();
    });

    if (logoPath != null && logoPath.isNotEmpty) {
      request.files.add(
        await http.MultipartFile.fromPath("logo", logoPath),
      );
    }

    if (signaturePath != null && signaturePath.isNotEmpty) {
      request.files.add(
        await http.MultipartFile.fromPath("signature_url", signaturePath),
      );
    }

    final response =
    await http.Response.fromStream(await request.send());

    return CompanyModel.fromJson(_handleResponse(response));
  }

  static Future<CompanyBankDetailsModel> saveCompanyBank({
    required String token,
    required String companyId,
    required CompanyBankDetailsModel bank,
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/companies/$companyId/bank/"),
      headers: {
        ..._headers(token),
        "Content-Type": "application/json",
      },
      body: jsonEncode(bank.toJson()),
    );

    return CompanyBankDetailsModel.fromJson(_handleResponse(res));
  }

  /* ================= INVOICES ================= */

  static Future<List<InvoiceModel>> getInvoices(String token) async {
    final res = await http.get(
      Uri.parse("$baseUrl/invoices/"),
      headers: _headers(token),
    );

    final data = _handleResponse(res);
    if (data is List) {
      return data.map((e) => InvoiceModel.fromJson(e)).toList();
    }
    return [];
  }

  static Future<InvoiceModel> createInvoice(
      String token,
      Map<String, dynamic> body,
      ) async {
    final res = await http.post(
      Uri.parse("$baseUrl/invoices/"),
      headers: {
        ..._headers(token),
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    return InvoiceModel.fromJson(_handleResponse(res));
  }

  static Future<InvoiceReviewModel> getInvoiceReview({
    required String token,
    required String invoiceId,
  }) async {
    final res = await http.get(
      Uri.parse("$baseUrl/invoices/$invoiceId/"),
      headers: _headers(token),
    );

    return InvoiceReviewModel.fromJson(_handleResponse(res));
  }

  /* ================= PDF GENERATION ================= */

  static Future<InvoicePdfResponse?> generatePdf(
      String token,
      String invoiceId,
      String templateName,
      ) async {
    final res = await http.post(
      Uri.parse("$baseUrl/invoices/$invoiceId/generate-pdf/"),
      headers: {
        ..._headers(token),
        "Content-Type": "application/json",
      },
      body: jsonEncode({"template_name": templateName}),
    );

    final data = _handleResponse(res, allowUnauthorized: true);
    return data == null ? null : InvoicePdfResponse.fromJson(data);
  }

  /* ================= PDF DOWNLOAD ================= */

  static Future<File> downloadInvoicePdfInternal({
    required String token,
    required String invoiceId,
  }) async {
    final res = await http.get(
      Uri.parse("$baseUrl/invoices/$invoiceId/download/"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/pdf",
      },
    );

    if (res.statusCode != 200) {
      _handleResponse(res, allowUnauthorized: true);
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/INV-$invoiceId.pdf");

    await file.writeAsBytes(res.bodyBytes, flush: true);
    return file;
  }
}
