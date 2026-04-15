import 'package:flutter/material.dart';

import 'package:my_app/billing/models/invoice_review_model.dart';
import 'package:my_app/billing/models/pdf_design_option.dart';
import 'package:my_app/billing/screen/invoice_detail/invoice_detail_layout.dart';
import 'package:my_app/billing/services/billing_api.dart';
import 'package:my_app/billing/services/billing_dio_api.dart';
import 'package:my_app/billing/utils/pdf_saver.dart';
import 'package:my_app/billing/utils/pdf_design_mapper.dart';
import 'package:my_app/services/secure_storage_service.dart';

import '../theme/billing_theme.dart';
import '../widgets/billing_app_bar.dart';

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
    } catch (_) {
      _setError("Failed to load invoice");
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
      _showSnackBar("Issue failed");
    } finally {
      if (mounted) setState(() => actionLoading = false);
    }
  }

  Future<void> _saveDesignIfDraft() async {
    if (invoice == null || _token == null) return;
    if (invoice!.status.toUpperCase() != "DRAFT") return;
    if (_selectedPdfDesign == null) return;

    setState(() => actionLoading = true);
    try {
      final selectedId = canonicalPdfDesignId(_selectedPdfDesign!.id);
      await BillingApi.updateInvoiceDesign(token: _token!, invoiceId: invoice!.id, pdfDesign: selectedId);
      final refreshed = await BillingApi.getInvoiceReview(token: _token!, invoiceId: widget.invoiceId);
      if (!mounted) return;
      setState(() {
        invoice = refreshed;
        _selectedPdfDesign = _pickInitialDesign(current: refreshed.pdfDesign, options: _pdfDesigns);
      });
      _showSnackBar("PDF design updated", isError: false);
    } catch (_) {
      _showSnackBar("Failed to update design");
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
      final path = await savePdfBytes(bytes: bytes, filename: "INV-${invoice!.id}-$ts.pdf");
      _showSnackBar(path == null ? "Download started." : "Invoice saved locally.", isError: false);
    } catch (e) {
      _showSnackBar("Download failed");
    } finally {
      if (mounted) setState(() => actionLoading = false);
    }
  }

  Future<void> _share() async {
    // Share UI removed per design requirements.
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BillingTheme.scaffoldBg,
      appBar: billingAppBar(
        title: 'Invoice',
        onBack: () => Navigator.of(context).maybePop(),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (loading) {
      return const Center(child: CircularProgressIndicator(color: BillingTheme.purple));
    }
    if (_errorMessage != null) {
      return Center(
        child: Text(_errorMessage!, style: const TextStyle(color: BillingTheme.textMuted)),
      );
    }
    if (invoice == null) {
      return const Center(
        child: Text('Data missing', style: TextStyle(color: BillingTheme.textMuted)),
      );
    }

    return Stack(
      children: [
        InvoiceDetailLayout(
          inv: invoice!,
          onDownload: invoice!.status.toUpperCase() == 'DRAFT' ? () {
            _showSnackBar('Issue invoice to enable PDF download.');
          } : _download,
          onIssue: invoice!.status.toUpperCase() == 'DRAFT' ? _issue : null,
        ),
        if (actionLoading) _buildLoadingOverlay(),
      ],
    );
  }

  Widget _buildLoadingOverlay() => Container(
    color: BillingTheme.scaffoldBg.withValues(alpha: 0.85),
    child: const Center(child: CircularProgressIndicator(color: BillingTheme.purple)),
  );

  // Removed bottom bar actions to match the requested UI.
}