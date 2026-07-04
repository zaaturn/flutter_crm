import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/billing/models/invoice_review_model.dart';
import 'package:my_app/billing/models/pdf_design_option.dart';
import 'package:my_app/billing/screen/invoice_detail/invoice_detail_layout.dart';
import 'package:my_app/billing/services/billing_api.dart';
import 'package:my_app/billing/services/billing_dio_api.dart';
import 'package:my_app/billing/utils/pdf_design_mapper.dart';
import 'package:my_app/services/secure_storage_service.dart';

import '../theme/billing_adaptive_theme.dart';
import '../widgets/billing_app_bar.dart';
import '../navigation/billing_flow_controller.dart';

class InvoiceReviewScreen extends StatefulWidget {
  final String invoiceId;

  const InvoiceReviewScreen({
    super.key,
    required this.invoiceId,
  });

  @override
  State<InvoiceReviewScreen> createState() => _InvoiceReviewScreenState();
}

class _InvoiceReviewScreenState extends State<InvoiceReviewScreen> {
  final SecureStorageService _storage = SecureStorageService();

  InvoiceReviewModel? invoice;
  String? _token;
  String? _errorMessage;

  bool loading = true;
  bool actionLoading = false;

  List<PdfDesignOption> _pdfDesigns = [];
  PdfDesignOption? _selectedPdfDesign;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final token = await _storage.readToken();
      if (token == null) {
        _setError("Authentication required");
        return;
      }
      _token = token;
      _pdfDesigns = await BillingApi.getPdfDesigns(token);
      final data = await BillingApi.getInvoiceReview(token: token, invoiceId: widget.invoiceId);

      if (!mounted) return;
      setState(() {
        invoice = data;
        _selectedPdfDesign = _pickInitialDesign(current: data.pdfDesign, options: _pdfDesigns);
        loading = false;
      });
    } catch (e) {
      _setError("Failed to sync invoice details.");
    }
  }

  void _setError(String message) {
    if (!mounted) return;
    setState(() {
      _errorMessage = message;
      loading = false;
    });
  }

  PdfDesignOption? _pickInitialDesign({required String? current, required List<PdfDesignOption> options}) {
    if (options.isEmpty) return null;
    if (current != null && current.isNotEmpty) {
      final canonicalCurrent = canonicalPdfDesignId(current);
      for (final o in options) {
        if (canonicalPdfDesignId(o.id) == canonicalCurrent) return o;
      }
    }
    return options.firstWhere((d) => d.id.toUpperCase() == "MINIMAL", orElse: () => options.first);
  }

  Future<void> _issue() async {
    if (invoice == null || _token == null) return;
    setState(() => actionLoading = true);
    try {
      await BillingApi.issueInvoice(
        token: _token!,
        invoiceId: invoice!.id,
        pdfDesign: _selectedPdfDesign == null ? null : canonicalPdfDesignId(_selectedPdfDesign!.id),
      );
      final data = await BillingApi.getInvoiceReview(token: _token!, invoiceId: widget.invoiceId);
      if (!mounted) return;
      setState(() {
        invoice = data;
        _selectedPdfDesign = _pickInitialDesign(current: data.pdfDesign, options: _pdfDesigns);
      });
      _showSnackBar("Invoice issued successfully", isError: false);
    } catch (_) {
      _showSnackBar("Issue failed.");
    } finally {
      if (mounted) setState(() => actionLoading = false);
    }
  }

  Future<void> _download() async {
    if (invoice == null || _token == null) return;
    setState(() => actionLoading = true);
    try {
      final bytes = await BillingDioApi.downloadInvoicePdfBytes(invoiceId: invoice!.id);
      final ts = DateTime.now().millisecondsSinceEpoch;
      if (!mounted) return;
      await BillingFlowController.saveAndOpenPdf(
        context,
        bytes: bytes,
        filename: "INV-${invoice!.id}-$ts.pdf",
      );
    } catch (e) {
      _showSnackBar("Download failed.");
    } finally {
      if (mounted) setState(() => actionLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
        backgroundColor: isError ? const Color(0xFFDC2626) : const Color(0xFF0C56D0),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = BillingAdaptiveTheme.isMobile(context);

    return Scaffold(
      backgroundColor: BillingAdaptiveTheme.canvas(context),
      appBar: billingAppBar(
        title: 'Invoice Review',
        onBack: () => Navigator.of(context).maybePop(),
      ),
      body: _buildBody(isMobile),
    );
  }

  Widget _buildBody(bool isMobile) {
    if (loading) {
      return Center(
        child: CircularProgressIndicator(color: isMobile ? const Color(0xFF8D5B39) : const Color(0xFF0C56D0)),
      );
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    if (invoice == null) return const Center(child: Text('Data error.'));

    return Stack(
      children: [
        // FIX: Replaced CustomScrollView/IntrinsicHeight with a simpler Column layout
        // This allows the inner LayoutBuilder to receive proper width constraints.
        SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(isMobile ? 16 : 40, 24, isMobile ? 16 : 40, 140),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: InvoiceDetailLayout(
                    inv: invoice!,
                    onDownload: invoice!.status.toUpperCase() == 'DRAFT'
                        ? () => _showSnackBar('Issue the invoice first.')
                        : _download,
                    onIssue: invoice!.status.toUpperCase() == 'DRAFT' ? _issue : null,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (actionLoading)
          Container(
            color: Colors.white.withOpacity(0.7),
            child: const Center(child: CircularProgressIndicator(color: Color(0xFF8D5B39))),
          ),
      ],
    );
  }
}