import 'package:flutter/material.dart';
import 'package:my_app/services/secure_storage_service.dart';

import '../models/company_model.dart';
import '../models/invoice_item_model.dart';
import '../models/invoice_model.dart';
import '../models/pdf_design_option.dart';
import '../services/billing_api.dart';
import '../theme/billing_theme.dart';
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
        backgroundColor: isError ? const Color(0xFFDC2626) : BillingTheme.purple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      return Scaffold(
        backgroundColor: BillingTheme.scaffoldBg,
        body: const Center(
          child: CircularProgressIndicator(color: BillingTheme.purple),
        ),
      );
    }

    return Scaffold(
      backgroundColor: BillingTheme.scaffoldBg,
      appBar: billingAppBar(
        title: 'Create invoice',
        onBack: () => Navigator.of(context).maybePop(),
      ),
      body: LayoutBuilder(
        builder: (context, c) {
          final wide = c.maxWidth >= 1100;
          final left = _leftColumn(wide: wide);
          final right = _rightColumn(wide: wide);

          if (!wide) {
            return Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 120),
                  children: [
                    left,
                    const SizedBox(height: 16),
                    right,
                  ],
                ),
                _bottomBar(),
              ],
            );
          }

          return Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 120),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1280),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: left),
                        const SizedBox(width: 18),
                        Expanded(flex: 2, child: right),
                      ],
                    ),
                  ),
                ),
              ),
              _bottomBar(),
            ],
          );
        },
      ),
    );
  }

  Widget _bottomBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: BillingTheme.surface,
          border: const Border(top: BorderSide(color: BillingTheme.border)),
          boxShadow: [
            BoxShadow(
              color: BillingTheme.purple.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _saving ? null : () => Navigator.of(context).maybePop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: BillingTheme.textPrimary,
                    side: const BorderSide(color: BillingTheme.border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Discard', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saving ? null : _createInvoice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BillingTheme.purple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Save & Continue', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _leftColumn({required bool wide}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Create new invoice', style: BillingTheme.titleLarge()),
        const SizedBox(height: 6),
        Text('Draft', style: BillingTheme.body()),
        const SizedBox(height: 18),
        InvoiceSectionCard(
          icon: Icons.business_rounded,
          title: 'Sender infrastructure',
          child: BillingFromDropdown(
            companies: _companies,
            selected: _state.selectedCompany,
            onChanged: (c) => setState(() => _state.selectedCompany = c),
          ),
        ),
        const SizedBox(height: 14),
        InvoiceSectionCard(
          icon: Icons.person_outline_rounded,
          title: 'Receiver entity',
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: InvoiceTextField(
                      controller: _state.clientNameCtrl,
                      label: 'Client legal name',
                      hint: 'e.g. Acme Corp',
                      requiredField: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InvoiceTextField(
                      controller: _state.clientGstinCtrl,
                      label: 'Tax ID / GSTIN',
                      hint: 'e.g. GST123...',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              InvoiceTextField(
                controller: _state.clientAddressCtrl,
                label: 'Operational address',
                hint: 'Street address, building, suite...',
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              InvoiceTextField(
                controller: _state.clientStateCtrl,
                label: 'Jurisdiction / state',
                hint: 'State',
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        InvoiceSectionCard(
          icon: Icons.list_alt_rounded,
          title: 'Ledger items',
          child: _itemsEditor(),
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
          title: 'Visual schematic',
          child: PdfDesignGrid(
            options: _pdfDesigns,
            selected: _state.selectedDesign,
            onSelect: (d) => setState(() => _state.selectedDesign = d),
          ),
        ),
        const SizedBox(height: 14),
        InvoiceSectionCard(
          icon: Icons.calendar_month_rounded,
          title: 'Temporal data',
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

  Widget _itemsEditor() {
    return Column(
      children: [
        ..._state.items.asMap().entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ItemEditorCard(
                  item: e.value,
                  onRemove: () => setState(() => _state.items.removeAt(e.key)),
                  onChanged: () => setState(() {}),
                ),
              ),
            ),
        OutlinedButton.icon(
          onPressed: () => setState(() => _state.items.add(InvoiceItemModel.empty())),
          icon: const Icon(Icons.add_circle_outline_rounded),
          label: const Text('Append item line'),
          style: OutlinedButton.styleFrom(
            foregroundColor: BillingTheme.purple,
            side: const BorderSide(color: BillingTheme.border),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ],
    );
  }
}

class _ItemEditorCard extends StatelessWidget {
  final InvoiceItemModel item;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  const _ItemEditorCard({
    required this.item,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BillingTheme.scaffoldBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BillingTheme.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: item.name)
                    ..selection = TextSelection.collapsed(offset: item.name.length),
                  onChanged: (v) {
                    item.name = v;
                    onChanged();
                  },
                  decoration: InputDecoration(
                    labelText: 'Service / product',
                    filled: true,
                    fillColor: BillingTheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: BillingTheme.border),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline_rounded),
                color: const Color(0xFFDC2626),
                tooltip: 'Remove',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _numField(
                  label: 'HSN/SAC',
                  value: item.hsnSacCode,
                  onChanged: (v) {
                    item.hsnSacCode = v;
                    onChanged();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _numField(
                  label: 'Qty',
                  value: item.quantity.toString(),
                  onChanged: (v) {
                    item.quantity = double.tryParse(v) ?? item.quantity;
                    onChanged();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _numField(
                  label: 'Unit price',
                  value: item.unitPrice == 0 ? '' : item.unitPrice.toString(),
                  onChanged: (v) {
                    item.unitPrice = double.tryParse(v) ?? item.unitPrice;
                    onChanged();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _numField(
                  label: 'Tax %',
                  value: item.taxRate.toString(),
                  onChanged: (v) {
                    item.taxRate = double.tryParse(v) ?? item.taxRate;
                    onChanged();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _numField({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      controller: TextEditingController(text: value)
        ..selection = TextSelection.collapsed(offset: value.length),
      onChanged: onChanged,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: BillingTheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: BillingTheme.border),
        ),
      ),
    );
  }
}