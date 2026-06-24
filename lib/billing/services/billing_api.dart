import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:cross_file/cross_file.dart';

import '../models/company_model.dart';
import '../models/CompanyBankDetailsModel.dart';
import '../models/invoice_model.dart';
import '../models/invoice_review_model.dart';
import '../models/invoice_pdf_response.dart';
import '../models/pdf_design_option.dart';
import '../models/invoice_item_model.dart';
import '../../services/secure_storage_service.dart';
import 'package:my_app/core/auth/auth_session_redirect.dart';

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
  ValidationException(super.message);
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

  static String get baseUrl => "${_base.replaceAll(RegExp(r'/+$'), '')}/api/billing";

  static final SecureStorageService _storage = SecureStorageService();

  // Reuse the same accounts base as the rest of the app for refresh.
  static String get _accountsBase =>
      "${_base.replaceAll(RegExp(r'/+$'), '')}/api/accounts/crm";

  /* ================= HEADERS ================= */

  static Map<String, String> _headers(String token) => {
    "Authorization": "Bearer $token",
    "Accept": "application/json",
  };

  static Future<String?> _refreshAccessToken() async {
    final refresh = await _storage.readRefreshToken();
    if (refresh == null || refresh.isEmpty) return null;

    try {
      final res = await http.post(
        Uri.parse("$_accountsBase/token/refresh/"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"refresh": refresh}),
      );

      if (res.statusCode < 200 || res.statusCode >= 300) return null;
      final data = jsonDecode(res.body);
      final access = data["access"]?.toString();
      if (access == null || access.isEmpty) return null;

      await _storage.saveToken(access);
      if (data["refresh"] != null) {
        final newRefresh = data["refresh"]?.toString();
        if (newRefresh != null && newRefresh.isNotEmpty) {
          await _storage.saveRefreshToken(newRefresh);
        }
      }
      return access;
    } catch (_) {
      return null;
    }
  }

  /// Executes an HTTP request. If it returns 401, refresh token and retry once.
  static Future<http.Response> _sendWithRefresh(
    Future<http.Response> Function(String token) run,
  ) async {
    final token = await _storage.readToken();
    if (token == null || token.isEmpty) {
      AuthSessionRedirect.onAuthFailure(statusCode: 401);
      throw UnauthorizedException();
    }

    var res = await run(token);
    if (res.statusCode != 401) return res;

    final refreshed = await _refreshAccessToken();
    if (refreshed == null) return res;

    res = await run(refreshed);
    return res;
  }

  /// Multipart requests must be rebuilt for retries (streams are single-use).
  static Future<http.Response> _sendMultipartWithRefresh(
    Future<http.MultipartRequest> Function(String token) build,
  ) async {
    final token = await _storage.readToken();
    if (token == null || token.isEmpty) {
      AuthSessionRedirect.onAuthFailure(statusCode: 401);
      throw UnauthorizedException();
    }

    Future<http.Response> send(String t) async {
      final req = await build(t);
      final streamed = await req.send();
      return http.Response.fromStream(streamed);
    }

    var res = await send(token);
    if (res.statusCode != 401) return res;

    final refreshed = await _refreshAccessToken();
    if (refreshed == null) return res;

    res = await send(refreshed);
    return res;
  }

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
        AuthSessionRedirect.onAuthFailure(
          error: response.body,
          statusCode: 401,
        );
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
    final res = await _sendWithRefresh(
      (t) => http.get(
        Uri.parse("$baseUrl/companies/me/"),
        headers: _headers(t),
      ),
    );

    final data = _handleResponse(res);
    return data == null ? null : CompanyModel.fromJson(data);
  }

  static Future<List<CompanyModel>> getCompanies(String token) async {
    final res = await _sendWithRefresh(
      (t) => http.get(
        Uri.parse("$baseUrl/companies/dropdown/"),
        headers: _headers(t),
      ),
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
        XFile? logoFile,
        XFile? signatureFile,
      }) async {
    final uri = Uri.parse("$baseUrl/companies/");
    final response = await _sendMultipartWithRefresh((t) async {
      final request = http.MultipartRequest("POST", uri)
        ..headers.addAll(_headers(t));

      body.forEach((key, value) {
        if (value == null) return;
        request.fields[key] =
        value is Map ? jsonEncode(value) : value.toString();
      });

      Future<void> attachXFile(String field, XFile? file) async {
        if (file == null) return;

        if (kIsWeb) {
          final Uint8List bytes = await file.readAsBytes();
          request.files.add(
            http.MultipartFile.fromBytes(
              field,
              bytes,
              filename: file.name.isNotEmpty ? file.name : 'upload',
            ),
          );
          return;
        }

        request.files.add(
          await http.MultipartFile.fromPath(field, file.path),
        );
      }

      await attachXFile("logo", logoFile);
      await attachXFile("signature_url", signatureFile);
      return request;
    });

    return CompanyModel.fromJson(_handleResponse(response));
  }

  static Future<CompanyBankDetailsModel> saveCompanyBank({
    required String token,
    required String companyId,
    required CompanyBankDetailsModel bank,
  }) async {
    final res = await _sendWithRefresh(
      (t) => http.post(
        Uri.parse("$baseUrl/companies/$companyId/bank/"),
        headers: {
          ..._headers(t),
          "Content-Type": "application/json",
        },
        body: jsonEncode(bank.toJson()),
      ),
    );

    return CompanyBankDetailsModel.fromJson(_handleResponse(res));
  }

  /* ================= INVOICES ================= */

  static Future<List<InvoiceModel>> getInvoices(String token) async {
    final res = await _sendWithRefresh(
      (t) => http.get(
        Uri.parse("$baseUrl/invoices/list/"),
        headers: _headers(t),
      ),
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
    final res = await _sendWithRefresh(
      (t) => http.post(
        Uri.parse("$baseUrl/invoices/"),
        headers: {
          ..._headers(t),
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      ),
    );

    return InvoiceModel.fromJson(_handleResponse(res));
  }

  /// Some backends don't accept nested `items` on invoice create.
  /// This helper creates the invoice first, then posts line items with `invoice: <id>`.
  static Future<InvoiceModel> createInvoiceWithItems({
    required Map<String, dynamic> invoiceBody,
    required List<InvoiceItemModel> items,
  }) async {
    // Always send items in a backend-compatible shape.
    final nestedBody = Map<String, dynamic>.from(invoiceBody)
      ..["items"] = items.map((e) => e.toJson()).toList();

    // 1) Try nested create first (many backends require items here).
    final nestedRes = await _sendWithRefresh(
      (t) => http.post(
        Uri.parse("$baseUrl/invoices/"),
        headers: {
          ..._headers(t),
          "Content-Type": "application/json",
        },
        body: jsonEncode(nestedBody),
      ),
    );

    if (nestedRes.statusCode == 200 || nestedRes.statusCode == 201) {
      final data = _handleResponse(nestedRes) as Map<String, dynamic>;
      return InvoiceModel.fromJson(data);
    }

    // If nested create fails with 400, decide whether to fall back to 2-step.
    if (nestedRes.statusCode != 400) {
      _handleResponse(nestedRes);
    }

    // No invoice-item creation endpoints exist in your backend routes, so we cannot
    // fall back to a 2-step "header then items" flow from the app side.
    //
    // If backend returns `{invoice:[...], line_total:[...]}`, it is validating the
    // invoice-item serializer at the wrong level. Backend must either:
    // - Accept nested items on POST invoices/ (and set `invoice` on each item), OR
    // - Add an endpoint to create items after invoice creation.
    throw ValidationException(nestedRes.body);
  }

  static Future<InvoiceReviewModel> getInvoiceReview({
    required String token,
    required String invoiceId,
  }) async {
    final res = await _sendWithRefresh(
      (t) => http.get(
        Uri.parse("$baseUrl/invoices/$invoiceId/"),
        headers: _headers(t),
      ),
    );

    return InvoiceReviewModel.fromJson(_handleResponse(res));
  }

  /* ================= PDF DESIGNS ================= */

  /// Backend: `GET invoices/pdf-designs/` → list of `{id,label,description}`
  static Future<List<PdfDesignOption>> getPdfDesigns(String token) async {
    final res = await _sendWithRefresh(
      (t) => http.get(
        Uri.parse("$baseUrl/invoices/pdf-designs/"),
        headers: _headers(t),
      ),
    );

    final data = _handleResponse(res);
    if (data is List) {
      return data
          .map((e) => PdfDesignOption.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /* ================= INVOICE DESIGN (DRAFT ONLY) ================= */

  /// Backend: `PATCH invoices/<id>/design/` with `{pdf_design:"MINIMAL"}`
  static Future<void> updateInvoiceDesign({
    required String token,
    required String invoiceId,
    required String pdfDesign,
  }) async {
    final res = await _sendWithRefresh(
      (t) => http.patch(
        Uri.parse("$baseUrl/invoices/$invoiceId/design/"),
        headers: {
          ..._headers(t),
          "Content-Type": "application/json",
        },
        body: jsonEncode({"pdf_design": pdfDesign}),
      ),
    );
    _handleResponse(res);
  }

  /* ================= ISSUE INVOICE ================= */

  /// Backend: `POST invoices/<id>/issue/` with optional `{pdf_design:"..."}`
  static Future<InvoicePdfResponse?> issueInvoice({
    required String token,
    required String invoiceId,
    String? pdfDesign,
  }) async {
    final res = await _sendWithRefresh(
      (t) => http.post(
        Uri.parse("$baseUrl/invoices/$invoiceId/issue/"),
        headers: {
          ..._headers(t),
          "Content-Type": "application/json",
        },
        body: jsonEncode(pdfDesign == null ? {} : {"pdf_design": pdfDesign}),
      ),
    );

    final data = _handleResponse(res, allowUnauthorized: true);
    return data == null ? null : InvoicePdfResponse.fromJson(data);
  }

  /* ================= PDF DOWNLOAD ================= */

  static Future<Uint8List> downloadInvoicePdfBytes({
    required String token,
    required String invoiceId,
  }) async {
    final res = await _sendWithRefresh(
      (t) => http.get(
        Uri.parse("$baseUrl/invoices/$invoiceId/download/"),
        headers: {
          "Authorization": "Bearer $t",
          "Accept": "application/pdf",
        },
      ),
    );

    if (res.statusCode != 200) {
      _handleResponse(res, allowUnauthorized: true);
    }

    final bytes = Uint8List.fromList(res.bodyBytes);
    final contentType = (res.headers["content-type"] ?? "").toLowerCase();
    final looksLikePdf = bytes.length >= 4 &&
        bytes[0] == 0x25 && // %
        bytes[1] == 0x50 && // P
        bytes[2] == 0x44 && // D
        bytes[3] == 0x46; // F

    if (!looksLikePdf && !contentType.contains("application/pdf")) {
      // Backend often returns JSON errors/HTML while still being 200 in some setups.
      // Don't save those bytes as a .pdf; surface the message.
      final bodyText = utf8.decode(bytes, allowMalformed: true).trim();
      throw ApiException(
        "Download did not return a PDF. content-type=$contentType body=$bodyText",
      );
    }

    return bytes;
  }

  static Future<File> downloadInvoicePdfInternal({
    required String token,
    required String invoiceId,
  }) async {
    final bytes = await downloadInvoicePdfBytes(token: token, invoiceId: invoiceId);
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/INV-$invoiceId.pdf");
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }
}
