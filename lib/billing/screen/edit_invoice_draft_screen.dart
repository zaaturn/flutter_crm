import 'package:flutter/material.dart';
import '../models/company_model.dart';
import '../models/invoice_item_model.dart';
import '../models/pdf_design_option.dart';
import '../services/billing_api.dart';
import '../services/billing_dio_api.dart';
import '../theme/billing_theme.dart';
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
      final addr = (client['address'] is Map<String, dynamic>)
          ? (client['address'] as Map<String, dynamic>)
          : <String, dynamic>{};

      // Backend may not include `client_manual` on GET; prefer `billing_to` / `client`.
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
      final fallbackGstin =
          (billingTo['gstin'] ?? (json['client'] is Map<String, dynamic> ? (json['client']['gstin']) : null) ?? '')
              .toString();
      final fallbackAddress = (billingToAddr['full_address'] ??
              billingTo['address'] ??
              (json['client'] is Map<String, dynamic> ? (json['client']['address']?['full_address']) : null) ??
              '')
          .toString();

      _clientNameCtrl.text = (client['name'] ?? fallbackName).toString();
      _clientGstinCtrl.text = (client['gstin'] ?? fallbackGstin).toString();
      _clientAddressCtrl.text =
          (addr['full_address'] ?? client['address'] ?? fallbackAddress).toString();
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
        _selectedCompany = _companies.firstWhere(
              (c) => c.id == companyId,
          orElse: () => _companies.first,
        );
      }

      if (_pdfDesigns.isNotEmpty) {
        final canonical = pdfDesign == null ? null : canonicalPdfDesignId(pdfDesign);
        _selectedPdfDesign = canonical == null
            ? _pdfDesigns.first
            : _pdfDesigns.firstWhere(
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
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF059669),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: BillingTheme.scaffoldBg,
        body: const Center(child: CircularProgressIndicator(color: BillingTheme.purple)),
      );
    }

    final isDraft = (_status ?? '').toUpperCase() == 'DRAFT';

    return Scaffold(
      backgroundColor: BillingTheme.scaffoldBg,
      appBar: billingAppBar(
        title: isDraft ? 'Edit draft' : 'Invoice (read-only)',
        onBack: () => Navigator.of(context).maybePop(),
      ),
      body: Stack(
        children: [
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(40, 32, 40, 140),
                children: [
                  _sectionHeader("SENDER INFRASTRUCTURE"),
                  BillingFromDropdown(
                    companies: _companies,
                    selected: _selectedCompany,
                    onChanged: isDraft ? (c) => setState(() => _selectedCompany = c) : (_) {},
                  ),
                  const SizedBox(height: 32),
                  _sectionHeader("VISUAL SCHEMATIC"),
                  _pdfDesignPicker(enabled: isDraft),
                  const SizedBox(height: 32),
                  _sectionHeader("TEMPORAL DATA"),
                  Row(
                    children: [
                      Expanded(child: _dateField(label: "INVOICE DATE", value: invoiceDate, enabled: isDraft, onChanged: (d) => setState(() => invoiceDate = d))),
                      const SizedBox(width: 16),
                      Expanded(child: _dateField(label: "MATURITY DATE", value: dueDate, enabled: isDraft, onChanged: (d) => setState(() => dueDate = d))),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _sectionHeader("RECEIVER ENTITY"),
                  _field("CLIENT LEGAL NAME", _clientNameCtrl, required: true, enabled: isDraft),
                  Row(
                    children: [
                      Expanded(child: _field("TAX ID / GSTIN", _clientGstinCtrl, enabled: isDraft)),
                      const SizedBox(width: 16),
                      Expanded(child: _field("JURISDICTION / STATE", _clientStateCtrl, enabled: isDraft)),
                    ],
                  ),
                  _field("OPERATIONAL ADDRESS", _clientAddressCtrl, enabled: isDraft),
                  const SizedBox(height: 32),
                  _sectionHeader("LEDGER ITEMS"),
                  _itemsSection(enabled: isDraft),
                  const SizedBox(height: 48),
                  AmountSummary(items: items),
                ],
              ),
            ),
          ),
          _bottomSaveBar(enabled: isDraft),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w900,
            color: BillingTheme.purple,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(child: Container(height: 1, color: BillingTheme.border)),
      ],
    ),
  );

  Widget _field(String label, TextEditingController controller, {bool required = false, bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        enabled: enabled,
        style: TextStyle(
          color: enabled ? BillingTheme.textPrimary : BillingTheme.textMuted,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          labelText: required ? "${label.toUpperCase()} *" : label.toUpperCase(),
          labelStyle: const TextStyle(color: BillingTheme.textMuted, fontSize: 10, letterSpacing: 1),
          filled: true,
          fillColor: BillingTheme.scaffoldBg,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: BillingTheme.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: BillingTheme.purple, width: 1.5),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: BillingTheme.border),
          ),
        ),
      ),
    );
  }

  Widget _dateField({required String label, required DateTime value, required ValueChanged<DateTime> onChanged, required bool enabled}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: !enabled ? null : () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: value,
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
            builder: (ctx, child) => Theme(
              data: BillingTheme.datePickerTheme(ctx),
              child: child!,
            ),
          );
          if (picked != null) onChanged(picked);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: BillingTheme.textMuted, fontSize: 10, letterSpacing: 1),
            filled: true,
            fillColor: BillingTheme.scaffoldBg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: BillingTheme.border),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: BillingTheme.border),
            ),
          ),
          child: Text(
            _formatDate(value),
            style: TextStyle(
              color: enabled ? BillingTheme.textPrimary : BillingTheme.textMuted,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _pdfDesignPicker({required bool enabled}) {
    return DropdownButtonFormField<PdfDesignOption>(
      initialValue: _selectedPdfDesign,
      dropdownColor: BillingTheme.surface,
      style: TextStyle(
        color: enabled ? BillingTheme.textPrimary : BillingTheme.textMuted,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: "SELECT PDF DESIGN",
        labelStyle: const TextStyle(color: BillingTheme.textMuted, fontSize: 10, letterSpacing: 1),
        filled: true,
        fillColor: BillingTheme.scaffoldBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: BillingTheme.border),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: BillingTheme.border),
        ),
      ),
      items: _pdfDesigns.map((d) => DropdownMenuItem(value: d, child: Text(d.label.isNotEmpty ? d.label : d.id))).toList(),
      onChanged: !enabled ? null : (v) => setState(() => _selectedPdfDesign = v),
    );
  }

  Widget _itemsSection({required bool enabled}) {
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
              foregroundColor: BillingTheme.purple,
              side: const BorderSide(color: BillingTheme.purple),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ]
      ],
    );
  }

  Widget _bottomSaveBar({required bool enabled}) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.fromLTRB(40, 20, 40, 40),
        decoration: const BoxDecoration(
          color: BillingTheme.surface,
          border: Border(top: BorderSide(color: BillingTheme.border)),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: (!enabled || _saving) ? null : _updateDraft,
            style: ElevatedButton.styleFrom(
              backgroundColor: enabled ? BillingTheme.purple : BillingTheme.border,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: _saving
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(
                    enabled ? 'Update draft' : 'Issued',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}