import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'package:my_app/billing/models/invoice_review_model.dart';
import 'package:my_app/billing/services/billing_api.dart';
import 'package:my_app/services/secure_storage_service.dart';

import '../widgets/invoice_review_screen_widgets/invoice_summary_card.dart';
import '../widgets/invoice_review_screen_widgets/invoice_info_card.dart'
as info_card;
import '../widgets/invoice_review_screen_widgets/invoice_item_card.dart'
as item_card;
import '../widgets/invoice_review_screen_widgets/invoice_action_button.dart';

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

  static const Color primaryIndigo = Color(0xFF4F46E5);
  static const Color slateDark = Color(0xFF111827);
  static const Color backgroundGray = Color(0xFFF9FAFB);

  InvoiceReviewModel? invoice;
  String? _token;
  String? _errorMessage;

  bool loading = true;
  bool actionLoading = false;

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

      final data = await BillingApi.getInvoiceReview(
        token: token,
        invoiceId: widget.invoiceId,
      );

      if (!mounted) return;
      setState(() {
        invoice = data;
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

  /* ================= ACTIONS ================= */

  Future<void> _download() async {
    if (invoice == null || _token == null) return;

    setState(() => actionLoading = true);
    try {
      await BillingApi.generatePdf(
        _token!,
        invoice!.id,
        "invoice_weasy.html",
      );

      final file = await BillingApi.downloadInvoicePdfInternal(
        token: _token!,
        invoiceId: invoice!.id,
      );

      _showSnackBar(
        "Invoice downloaded. Use Share to save or send.",
        isError: false,
      );

      debugPrint("Saved at: ${file.path}");
    } catch (e) {
      _showSnackBar("Download failed");
    } finally {
      if (mounted) setState(() => actionLoading = false);
    }
  }

  Future<void> _share() async {
    if (invoice == null || _token == null) return;

    setState(() => actionLoading = true);
    try {
      await BillingApi.generatePdf(
        _token!,
        invoice!.id,
        "invoice_weasy.html",
      );

      final file = await BillingApi.downloadInvoicePdfInternal(
        token: _token!,
        invoiceId: invoice!.id,
      );

      await Share.shareXFiles(
        [XFile(file.path)],
        text: "Invoice ${invoice!.invoiceNumber ?? ''}",
      );
    } catch (e) {
      _showSnackBar("Share failed");
    } finally {
      if (mounted) setState(() => actionLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
        isError ? const Color(0xFFDC2626) : const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /* ================= UI ================= */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        "Invoice Details",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: slateDark,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0,
      shape: Border(
        bottom: BorderSide(color: Colors.grey.shade200),
      ),
    );
  }

  Widget _buildBody() {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(primaryIndigo),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    if (invoice == null) {
      return const Center(child: Text("Invoice not found"));
    }

    return Stack(
      children: [
        _buildInvoiceContent(),
        if (actionLoading) _buildLoadingOverlay(),
      ],
    );
  }

  Widget _buildInvoiceContent() {
    final inv = invoice!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 120),
      children: [
        InvoiceSummaryCard(
          status: inv.status,
          invoiceNumber: inv.invoiceNumber,
          grandTotal: inv.grandTotal,
          invoiceDate: inv.invoiceDate,
        ),
        const SizedBox(height: 4),
        info_card.InvoiceInfoCard(
          title: "SENDER",
          icon: Icons.business_outlined,
          name: inv.billingFrom.name,
          address: inv.billingFrom.address,
          gst: inv.billingFrom.gstNumber,
          accentColor: primaryIndigo,
        ),
        info_card.InvoiceInfoCard(
          title: "RECIPIENT",
          icon: Icons.person_outline_rounded,
          name: inv.billingTo.name,
          address: inv.billingTo.address ?? "",
          gst: inv.billingTo.gstin ?? "",
          accentColor: primaryIndigo,
        ),
        const SizedBox(height: 4),
        item_card.InvoiceItemsCard(
          items: inv.items,
          subtotal: inv.subtotal,
          taxTotal: inv.taxTotal,
          grandTotal: inv.grandTotal,
        ),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.white.withOpacity(0.5),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget? _buildBottomBar() {
    if (invoice == null || _errorMessage != null) return null;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: InvoiceActionButtons(
        onDownload: _download,
        onShare: _share,
        isLoading: actionLoading,
      ),
    );
  }
}
