import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/services/secure_storage_service.dart';

import '../models/company_model.dart';
import '../models/invoice_item_model.dart';
import '../models/invoice_model.dart';
import '../models/pdf_design_option.dart';
import '../services/billing_api.dart';
import '../theme/billing_theme.dart';
import '../theme/billing_adaptive_theme.dart';
import '../utils/pdf_design_mapper.dart';
import '../widgets/billing_app_bar.dart';
import '../widgets/billing_from_dropdown.dart';

import 'create_invoice/create_invoice_models.dart';
import 'create_invoice/widgets/financial_recap_card.dart';
import 'create_invoice/widgets/invoice_section_card.dart';
import 'create_invoice/widgets/invoice_text_field.dart';
import 'create_invoice/widgets/pdf_design_grid.dart';
import 'create_invoice/widgets/temporal_card.dart';

class CreateInvoiceScreen extends StatefulWidget {
  final String companyId;
  const CreateInvoiceScreen({super.key, required this.companyId});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  static const Color _inkText = Color(0xFF1A1C1E);
  static const Color _accentOrange = Color(0xFFB14D1E);
  static const Color _clayFill = Color(0xFFF5E6DA);
  static const Color _paperWhite = Color(0xFFFFFDFB);

  final SecureStorageService _storage = SecureStorageService();
  final _clientNameCtrl = TextEditingController();
  final _clientGstinCtrl = TextEditingController();
  final _clientAddressCtrl = TextEditingController();
  final _clientStateCtrl = TextEditingController();

  List<CompanyModel> _companies = [];
  CompanyModel? _selectedCompany;
  List<PdfDesignOption> _pdfDesigns = [];
  PdfDesignOption? _selectedPdfDesign;

  String? _token;
  bool _initializing = true;
  bool _saving = false;

  late CreateInvoiceState _state;

  @override
  void initState() {
    super.initState();
    _state = CreateInvoiceState(
      selectedCompany: null,
      selectedDesign: null,
      invoiceDate: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 7)),
      clientNameCtrl: _clientNameCtrl,
      clientGstinCtrl: _clientGstinCtrl,
      clientAddressCtrl: _clientAddressCtrl,
      clientStateCtrl: _clientStateCtrl,
      items: [InvoiceItemModel.empty()],
    );
    _loadCompanies();
  }

  Future<void> _loadCompanies() async {
    try {
      _token = await _storage.readToken();
      if (_token == null) return;

      _companies = await BillingApi.getCompanies(_token!);
      _pdfDesigns = await BillingApi.getPdfDesigns(_token!);

      if (_pdfDesigns.isNotEmpty) {
        _selectedPdfDesign = _pdfDesigns.firstWhere(
              (d) => d.id.toUpperCase() == "MINIMAL",
          orElse: () => _pdfDesigns.first,
        );
      }

      if (_companies.isNotEmpty) {
        _selectedCompany = _companies.firstWhere(
              (c) => c.id == widget.companyId,
          orElse: () => _companies.first,
        );
      }
    } finally {
      if (mounted) setState(() => _initializing = false);
    }
    if (mounted) {
      setState(() {
        _state.selectedCompany = _selectedCompany;
        _state.selectedDesign = _selectedPdfDesign;
      });
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _createInvoice() async {
    if (_state.clientNameCtrl.text.trim().isEmpty) {
      _showSnack("Client name is required", isError: true);
      return;
    }
    if (_state.selectedCompany == null) return;

    setState(() => _saving = true);
    try {
      final body = {
        "company": _state.selectedCompany!.id,
        "client_manual": {
          "name": _state.clientNameCtrl.text.trim(),
          "gstin": _state.clientGstinCtrl.text.trim(),
          "address": {"full_address": _state.clientAddressCtrl.text.trim()},
          "state": _state.clientStateCtrl.text.trim(),
        },
        "invoice_date": _formatDate(_state.invoiceDate),
        "due_date": _formatDate(_state.dueDate),
        "items": _state.items.map((e) => e.toJson()).toList(),
        if (_state.selectedDesign != null)
          "pdf_design": canonicalPdfDesignId(_state.selectedDesign!.id),
      };

      final InvoiceModel invoice = await BillingApi.createInvoiceWithItems(
        invoiceBody: body,
        items: _state.items,
      );

      if (mounted) Navigator.of(context, rootNavigator: true).pop(invoice.id);
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
        backgroundColor: isError ? const Color(0xFFDC2626) : const Color(0xFF0C56D0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      return Scaffold(
        backgroundColor: BillingAdaptiveTheme.canvas(context),
        body: const Center(child: CircularProgressIndicator(color: Color(0xFF0C56D0))),
      );
    }

    return Scaffold(
      backgroundColor: BillingAdaptiveTheme.canvas(context),
      appBar: billingAppBar(
        title: 'Create Invoice',
        onBack: () => Navigator.of(context).maybePop(),
      ),
      body: LayoutBuilder(
        builder: (context, c) {
          final wide = c.maxWidth >= 1100;
          final left = _leftColumn(wide: wide);
          final right = _rightColumn(wide: wide);

          return Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(wide ? 20 : 16, 22, wide ? 20 : 16, 140),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1280),
                    child: wide
                        ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: left),
                        const SizedBox(width: 18),
                        Expanded(flex: 2, child: right),
                      ],
                    )
                        : Column(children: [left, const SizedBox(height: 16), right]),
                  ),
                ),
              ),
              _bottomBar(wide),
            ],
          );
        },
      ),
    );
  }

  Widget _bottomBar(bool wide) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final mint = BillingTheme.purple;
    final mintDark = BillingTheme.purpleDark;
    final mintLight = BillingTheme.purpleLight;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPadding),
        decoration: BoxDecoration(
          color: BillingTheme.surface,
          borderRadius: wide ? null : const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: BillingTheme.border)),
          boxShadow: [
            BoxShadow(
              color: mint.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _saving ? null : () => Navigator.of(context).maybePop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: mintLight,
                  foregroundColor: mintDark,
                  disabledBackgroundColor: mintLight.withValues(alpha: 0.6),
                  disabledForegroundColor: mintDark.withValues(alpha: 0.5),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: mint.withValues(alpha: 0.25)),
                  ),
                ),
                child: const Text('Discard', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _saving ? null : _createInvoice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: mint,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: mint.withValues(alpha: 0.5),
                  disabledForegroundColor: Colors.white70,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Save & Continue', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _leftColumn({required bool wide}) {
    final Color fieldFill = wide ? BillingTheme.surface : _clayFill;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Create New Invoice',
            style: GoogleFonts.manrope(
              fontSize: wide ? 32 : 28,
              fontWeight: FontWeight.w900,
              color: _inkText,
              letterSpacing: -0.5,
            )),
        const SizedBox(height: 6),
        Text('DRAFT MODE',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: _accentOrange,
            )),
        const SizedBox(height: 18),
        InvoiceSectionCard(
          icon: Icons.business_rounded,
          title: 'Sender Infrastructure',
          child: BillingFromDropdown(
            companies: _companies,
            selected: _state.selectedCompany,
            onChanged: (c) => setState(() => _state.selectedCompany = c),
          ),
        ),
        const SizedBox(height: 14),
        InvoiceSectionCard(
          icon: Icons.person_outline_rounded,
          title: 'Receiver Entity',
          child: Column(
            children: [
              _buildGrid(wide, [
                InvoiceTextField(
                  controller: _state.clientNameCtrl,
                  label: 'Client Legal Name',
                  hint: 'Acme Corp',
                  requiredField: true,
                  fillColor: fieldFill,
                ),
                InvoiceTextField(
                  controller: _state.clientGstinCtrl,
                  label: 'Tax ID / GSTIN',
                  hint: 'GST...',
                  fillColor: fieldFill,
                ),
              ]),
              const SizedBox(height: 12),
              InvoiceTextField(
                controller: _state.clientAddressCtrl,
                label: 'Operational Address',
                hint: 'Building, Suite...',
                maxLines: 2,
                fillColor: fieldFill,
              ),
              const SizedBox(height: 12),
              InvoiceTextField(
                controller: _state.clientStateCtrl,
                label: 'State',
                hint: 'State',
                fillColor: fieldFill,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        InvoiceSectionCard(
          icon: Icons.list_alt_rounded,
          title: 'Ledger Items',
          child: _itemsEditor(wide),
        ),
      ],
    );
  }

  Widget _rightColumn({required bool wide}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InvoiceSectionCard(
          icon: Icons.palette_outlined,
          title: 'Visual Schematic',
          child: PdfDesignGrid(
            options: _pdfDesigns,
            selected: _state.selectedDesign,
            onSelect: (d) => setState(() => _state.selectedDesign = d),
          ),
        ),
        const SizedBox(height: 14),
        InvoiceSectionCard(
          icon: Icons.calendar_month_rounded,
          title: 'Temporal Data',
          child: TemporalCard(
            invoiceDate: _state.invoiceDate,
            dueDate: _state.dueDate,
            onInvoiceChanged: (d) => setState(() => _state.invoiceDate = d),
            onDueChanged: (d) => setState(() => _state.dueDate = d),
          ),
        ),
        const SizedBox(height: 14),
        FinancialRecapCard(
          subtotal: _state.subtotal,
          taxTotal: _state.taxTotal,
          grandTotal: _state.grandTotal,
        ),
      ],
    );
  }

  Widget _buildGrid(bool wide, List<Widget> children) {
    if (!wide) return Column(children: children.map((w) => Padding(padding: const EdgeInsets.only(bottom: 12), child: w)).toList());
    return Row(children: children.map((w) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: w))).toList());
  }

  Widget _itemsEditor(bool wide) {
    return Column(
      children: [
        ..._state.items.asMap().entries.map(
              (e) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ItemEditorCard(
              wide: wide,
              item: e.value,
              onRemove: () => setState(() => _state.items.removeAt(e.key)),
              onChanged: () => setState(() {}),
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: () => setState(() => _state.items.add(InvoiceItemModel.empty())),
          icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
          label: const Text('APPEND ITEM LINE'),
          style: OutlinedButton.styleFrom(
            foregroundColor: _accentOrange,
            side: BorderSide(color: _accentOrange.withOpacity(0.15)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.1),
          ),
        ),
      ],
    );
  }
}

class _ItemEditorCard extends StatelessWidget {
  final bool wide;
  final InvoiceItemModel item;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  const _ItemEditorCard({
    required this.wide,
    required this.item,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final Color fill = wide ? BillingTheme.scaffoldBg : const Color(0xFFF5E6DA);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: wide ? BillingTheme.scaffoldBg : const Color(0xFFFFFDFB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _field(
                  label: 'Product / Service',
                  value: item.name,
                  fill: fill,
                  keyboardType: TextInputType.text,
                  hintText: 'Service or product',
                  onChanged: (v) {
                    item.name = v;
                    onChanged();
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                color: const Color(0xFFDC2626),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _field(
                      label: 'HSN',
                      value: item.hsnSacCode,
                      fill: fill,
                      keyboardType: TextInputType.number,
                      hintText: 'HSN/SAC',
                      onChanged: (v) {
                        item.hsnSacCode = v;
                        onChanged();
                      })),
              const SizedBox(width: 8),
              Expanded(
                  child: _field(
                      label: 'Qty',
                      value: item.quantity.toString(),
                      fill: fill,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      hintText: '0',
                      onChanged: (v) {
                        item.quantity = double.tryParse(v) ?? 1;
                        onChanged();
                      })),
              const SizedBox(width: 8),
              Expanded(
                  child: _field(
                      label: 'Price',
                      value: item.unitPrice.toString(),
                      fill: fill,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      hintText: '0.00',
                      onChanged: (v) {
                        item.unitPrice = v.isEmpty ? 0.0 : (double.tryParse(v) ?? item.unitPrice);
                        onChanged();
                      })),
              const SizedBox(width: 8),
              Expanded(
                  child: _field(
                      label: 'Tax %',
                      value: item.taxRate.toString(),
                      fill: fill,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      hintText: '0',
                      onChanged: (v) {
                        item.taxRate = double.tryParse(v) ?? 0;
                        onChanged();
                      })),
            ],
          ),
        ],
      ),
    );
  }

  Widget _field({
    required String label,
    required String value,
    required Color fill,
    required ValueChanged<String> onChanged,
    required TextInputType keyboardType,
    required String hintText,
  }) {
    return TextFormField(

      initialValue: (value == '0.0' || value == '0') ? '' : value,
      onChanged: onChanged,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1A1C1E),
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        hintStyle: GoogleFonts.inter(color: const Color(0xFF74777F).withOpacity(0.4)),
        labelStyle: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF74777F)),
        filled: true,
        fillColor: fill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }}