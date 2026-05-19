import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/company_model.dart';
import '../models/invoice_item_model.dart';
import '../models/pdf_design_option.dart';
import '../services/billing_api.dart';
import '../services/billing_dio_api.dart';
import 'package:intl/intl.dart';
import '../theme/billing_adaptive_theme.dart';
import '../utils/pdf_design_mapper.dart';
import '../widgets/amount_summary.dart';
import '../widgets/billing_app_bar.dart';
import '../widgets/billing_from_dropdown.dart';
import '../widgets/invoice_item_card.dart';
import '../../services/secure_storage_service.dart';

class EditInvoiceDraftScreen extends StatefulWidget {
  final String invoiceId;

  const EditInvoiceDraftScreen({super.key, required this.invoiceId});

  @override
  State<EditInvoiceDraftScreen> createState() => _EditInvoiceDraftScreenState();
}

class _EditInvoiceDraftScreenState extends State<EditInvoiceDraftScreen> {
  static const Color _inkText = Color(0xFF1A1C1E);
  static const Color _accentOrange = Color(0xFFB14D1E);
  static const Color _clayFill = Color(0xFFF5E6DA);
  static const Color _zaaturnInk = Color(0xFF8D5B39);

  final _clientNameCtrl = TextEditingController();
  final _clientGstinCtrl = TextEditingController();
  final _clientAddressCtrl = TextEditingController();
  final _clientStateCtrl = TextEditingController();

  DateTime invoiceDate = DateTime.now();
  DateTime dueDate = DateTime.now().add(const Duration(days: 7));

  List<InvoiceItemModel> items = [InvoiceItemModel.empty()];
  List<CompanyModel> _companies = [];
  CompanyModel? _selectedCompany;
  List<PdfDesignOption> _pdfDesigns = [];
  PdfDesignOption? _selectedPdfDesign;

  bool _loading = true;
  bool _saving = false;
  String? _status;

  @override
  void initState() {
    super.initState();
    _init();
  }

  String _formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  DateTime _parseDate(dynamic raw, DateTime fallback) {
    final s = raw?.toString();
    if (s == null || s.isEmpty) return fallback;
    try {
      return DateTime.parse(s);
    } catch (_) {
      return fallback;
    }
  }

  Future<void> _init() async {
    setState(() => _loading = true);
    try {
      final token = await _requireToken();
      _pdfDesigns = await BillingApi.getPdfDesigns(token);
      _companies = await BillingApi.getCompanies(token);

      final json = await BillingDioApi.getInvoiceDraft(invoiceId: widget.invoiceId);

      final status = (json['status'] ?? '').toString();
      final pdfDesign = json['pdf_design']?.toString();
      final companyId = (json['company']?['id'] ?? json['company'] ?? '').toString();

      final client = (json['client_manual'] is Map<String, dynamic>)
          ? (json['client_manual'] as Map<String, dynamic>)
          : <String, dynamic>{};

      final billingTo = (json['billing_to'] is Map<String, dynamic>)
          ? (json['billing_to'] as Map<String, dynamic>)
          : <String, dynamic>{};
      final billingToAddr = (billingTo['address'] is Map<String, dynamic>)
          ? (billingTo['address'] as Map<String, dynamic>)
          : <String, dynamic>{};

      final fallbackName = (billingTo['name'] ??
          (json['client'] is Map<String, dynamic> ? (json['client']['name']) : null) ??
          json['client_name'] ??
          '')
          .toString();

      _clientNameCtrl.text = (client['name'] ?? fallbackName).toString();
      _clientGstinCtrl.text = (client['gstin'] ?? (billingTo['gstin'] ?? '')).toString();
      _clientAddressCtrl.text = (client['address']?['full_address'] ?? billingToAddr['full_address'] ?? '').toString();
      _clientStateCtrl.text = (client['state'] ?? '').toString();

      invoiceDate = _parseDate(json['invoice_date'], DateTime.now());
      dueDate = _parseDate(json['due_date'], DateTime.now().add(const Duration(days: 7)));

      final rawItems = (json['items'] as List?) ?? const [];
      final parsedItems = rawItems
          .whereType<Map>()
          .map((e) => InvoiceItemModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      items = parsedItems.isEmpty ? [InvoiceItemModel.empty()] : parsedItems;

      if (_companies.isNotEmpty) {
        _selectedCompany = _companies.firstWhere((c) => c.id == companyId, orElse: () => _companies.first);
      }

      if (_pdfDesigns.isNotEmpty) {
        final canonical = pdfDesign == null ? null : canonicalPdfDesignId(pdfDesign);
        _selectedPdfDesign = _pdfDesigns.firstWhere(
              (d) => canonicalPdfDesignId(d.id) == canonical,
          orElse: () => _pdfDesigns.first,
        );
      }

      _status = status;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<String> _requireToken() async {
    final t = await SecureStorageService().readToken();
    if (t == null || t.isEmpty) throw Exception('Authentication required');
    return t;
  }

  Future<void> _updateDraft() async {
    if (_clientNameCtrl.text.trim().isEmpty) {
      _showSnack("Client name is required", isError: true);
      return;
    }
    setState(() => _saving = true);
    try {
      final body = <String, dynamic>{
        "company": _selectedCompany!.id,
        "client_manual": {
          "name": _clientNameCtrl.text.trim(),
          "gstin": _clientGstinCtrl.text.trim(),
          "address": {"full_address": _clientAddressCtrl.text.trim()},
          "state": _clientStateCtrl.text.trim(),
        },
        "invoice_date": _formatDate(invoiceDate),
        "due_date": _formatDate(dueDate),
        "items": items.map((e) => e.toJson()).toList(),
        if (_selectedPdfDesign != null) "pdf_design": canonicalPdfDesignId(_selectedPdfDesign!.id),
      };

      await BillingDioApi.updateInvoiceDraft(invoiceId: widget.invoiceId, body: body);
      if (!mounted) return;
      _showSnack("Invoice updated successfully");
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) _showSnack("Error: $e", isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF0C56D0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 840;
    if (_loading) {
      return Scaffold(
        backgroundColor: BillingAdaptiveTheme.bg(context),
        body: const Center(child: CircularProgressIndicator(color: Color(0xFF0C56D0))),
      );
    }

    final isDraft = (_status ?? '').toUpperCase() == 'DRAFT';

    return Scaffold(
      backgroundColor: BillingAdaptiveTheme.bg(context),
      appBar: billingAppBar(
        title: isDraft ? 'Edit Draft' : 'Review Invoice',
        onBack: () => Navigator.of(context).maybePop(),
      ),
      body: Stack(
        children: [
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: ListView(
                padding: EdgeInsets.fromLTRB(wide ? 40 : 16, 32, wide ? 40 : 16, 160),
                children: [
                  _sectionHeader(wide, "SENDER INFRASTRUCTURE"),
                  BillingFromDropdown(
                    companies: _companies,
                    selected: _selectedCompany,
                    onChanged: isDraft ? (c) => setState(() => _selectedCompany = c) : (_) {},
                  ),
                  const SizedBox(height: 32),
                  _sectionHeader(wide, "VISUAL SCHEMATIC"),
                  _pdfDesignPicker(wide, enabled: isDraft),
                  const SizedBox(height: 32),
                  _sectionHeader(wide, "TEMPORAL DATA"),
                  _buildGrid(wide, [
                    _dateField(wide, label: "INVOICE DATE", value: invoiceDate, enabled: isDraft, onChanged: (d) => setState(() => invoiceDate = d)),
                    _dateField(wide, label: "DUE DATE", value: dueDate, enabled: isDraft, onChanged: (d) => setState(() => dueDate = d)),
                  ]),
                  const SizedBox(height: 32),
                  _sectionHeader(wide, "RECEIVER ENTITY"),
                  _field(wide, "CLIENT LEGAL NAME", _clientNameCtrl, required: true, enabled: isDraft),
                  _buildGrid(wide, [
                    _field(wide, "TAX ID / GSTIN", _clientGstinCtrl, enabled: isDraft),
                    _field(wide, "JURISDICTION / STATE", _clientStateCtrl, enabled: isDraft),
                  ]),
                  _field(wide, "OPERATIONAL ADDRESS", _clientAddressCtrl, enabled: isDraft),
                  const SizedBox(height: 32),
                  _sectionHeader(wide, "LEDGER ITEMS"),
                  _itemsSection(wide, enabled: isDraft),
                  const SizedBox(height: 48),
                  AmountSummary(items: items),
                ],
              ),
            ),
          ),
          _bottomSaveBar(wide, enabled: isDraft),
        ],
      ),
    );
  }

  Widget _buildGrid(bool wide, List<Widget> children) {
    if (!wide) return Column(children: children);
    return Row(children: children.map((w) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: w))).toList());
  }

  Widget _sectionHeader(bool wide, String title) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Row(
      children: [
        Text(title,
          style: GoogleFonts.inter(
            fontSize: 10,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w900,
            color: wide ? const Color(0xFF0C56D0) : _accentOrange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Divider(color: wide ? const Color(0xFFE2E8F0) : _accentOrange.withOpacity(0.1))),
      ],
    ),
  );

  Widget _field(bool wide, String label, TextEditingController controller, {bool required = false, bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        enabled: enabled,
        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: _inkText),
        decoration: InputDecoration(
          labelText: required ? "$label *" : label,
          labelStyle: GoogleFonts.inter(color: const Color(0xFF74777F), fontSize: 11, fontWeight: FontWeight.w700),
          filled: true,
          fillColor: wide ? Colors.white : _clayFill,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: wide ? const Color(0xFFE2E8F0) : Colors.black.withOpacity(0.05)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: wide ? const Color(0xFF0C56D0) : _accentOrange, width: 1.5),
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _dateField(bool wide, {required String label, required DateTime value, required ValueChanged<DateTime> onChanged, required bool enabled}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: !enabled ? null : () async {
          final picked = await showDatePicker(context: context, initialDate: value, firstDate: DateTime(2020), lastDate: DateTime(2100));
          if (picked != null) onChanged(picked);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.inter(color: const Color(0xFF74777F), fontSize: 11, fontWeight: FontWeight.w700),
            filled: true,
            fillColor: wide ? Colors.white : _clayFill,
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: wide ? const Color(0xFFE2E8F0) : Colors.transparent)),
          ),
          child: Text(DateFormat('dd MMM yyyy').format(value), style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: _inkText)),
        ),
      ),
    );
  }

  Widget _pdfDesignPicker(bool wide, {required bool enabled}) {
    return DropdownButtonFormField<PdfDesignOption>(
      initialValue: _selectedPdfDesign,
      decoration: InputDecoration(
        labelText: "PDF SCHEMATIC",
        labelStyle: GoogleFonts.inter(color: const Color(0xFF74777F), fontSize: 11, fontWeight: FontWeight.w700),
        filled: true,
        fillColor: wide ? Colors.white : _clayFill,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: wide ? const Color(0xFFE2E8F0) : Colors.transparent)),
      ),
      items: _pdfDesigns.map((d) => DropdownMenuItem(value: d, child: Text(d.label))).toList(),
      onChanged: !enabled ? null : (v) => setState(() => _selectedPdfDesign = v),
    );
  }

  Widget _itemsSection(bool wide, {required bool enabled}) {
    return Column(
      children: [
        ...items.asMap().entries.map((e) => InvoiceItemCard(
          item: e.value,
          onRemove: enabled ? () => setState(() => items.removeAt(e.key)) : () {},
          onChanged: enabled ? () => setState(() {}) : () {},
        )),
        if (enabled) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => setState(() => items.add(InvoiceItemModel.empty())),
            icon: const Icon(Icons.add_circle_outline, size: 18),
            label: const Text("APPEND ITEM LINE"),
            style: OutlinedButton.styleFrom(
              foregroundColor: wide ? const Color(0xFF0C56D0) : _accentOrange,
              side: BorderSide(color: wide ? const Color(0xFF0C56D0) : _accentOrange.withOpacity(0.2)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ]
      ],
    );
  }

  Widget _bottomSaveBar(bool wide, {required bool enabled}) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: EdgeInsets.fromLTRB(wide ? 40 : 16, 20, wide ? 40 : 16, 20 + bottomPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: wide ? null : const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: Colors.black.withOpacity(0.05))),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: (!enabled || _saving) ? null : _updateDraft,
            style: ElevatedButton.styleFrom(
              backgroundColor: wide ? const Color(0xFF0C56D0) : _zaaturnInk,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: _saving
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(enabled ? 'Update Draft' : 'Invoice Issued', style: GoogleFonts.manrope(fontWeight: FontWeight.w900, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}