import 'package:flutter/material.dart';
import 'package:my_app/services/secure_storage_service.dart';

import '../models/invoice_item_model.dart';
import '../models/invoice_model.dart';
import '../models/company_model.dart';
import '../services/billing_api.dart';

import '../widgets/invoice_item_card.dart';
import '../widgets/amount_summary.dart';
import '../widgets/billing_from_dropdown.dart';

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

  DateTime invoiceDate = DateTime.now();
  DateTime dueDate = DateTime.now().add(const Duration(days: 7));

  List<InvoiceItemModel> items = [InvoiceItemModel.empty()];

  List<CompanyModel> _companies = [];
  CompanyModel? _selectedCompany;

  String? _token;
  bool _initializing = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadCompanies();
  }

  /* ---------------- LOAD COMPANIES ---------------- */

  Future<void> _loadCompanies() async {
    try {
      _token = await _storage.readToken();
      if (_token == null) return;

      _companies = await BillingApi.getCompanies(_token!);

      if (_companies.isNotEmpty) {
        _selectedCompany = _companies.firstWhere(
              (c) => c.id == widget.companyId,
          orElse: () => _companies.first,
        );
      }
    } finally {
      if (mounted) setState(() => _initializing = false);
    }
  }

  /* ---------------- DATE FORMATTER ---------------- */

  String _formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  /* ---------------- CREATE INVOICE ---------------- */

  Future<void> _createInvoice() async {
    if (_clientNameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Client name is required")),
      );
      return;
    }

    if (_selectedCompany == null) return;

    setState(() => _saving = true);

    try {
      final body = {
        "company": _selectedCompany!.id,
        "client_manual": {
          "name": _clientNameCtrl.text.trim(),
          "gstin": _clientGstinCtrl.text.trim(),
          "address": {
            "full_address": _clientAddressCtrl.text.trim(),
          },
          "state": _clientStateCtrl.text.trim(),
        },
        "invoice_date": _formatDate(invoiceDate),
        "due_date": _formatDate(dueDate),
        "items": items.map((e) => e.toJson()).toList(),
      };

      final InvoiceModel invoice =
      await BillingApi.createInvoice(_token!, body);


      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(invoice.id);

      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /* ---------------- UI ---------------- */

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Create Invoice",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
            children: [
              BillingFromDropdown(
                companies: _companies,
                selected: _selectedCompany,
                onChanged: (c) => setState(() => _selectedCompany = c),
              ),

              const SizedBox(height: 16),

              _sectionCard(
                title: "Invoice Dates",
                children: [
                  _dateField(
                    label: "Invoice Date",
                    value: invoiceDate,
                    onChanged: (d) => setState(() => invoiceDate = d),
                  ),
                  _dateField(
                    label: "Due Date",
                    value: dueDate,
                    onChanged: (d) => setState(() => dueDate = d),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              _sectionCard(
                title: "Client Details",
                children: [
                  _field("Client Name", _clientNameCtrl, required: true),
                  _field("GSTIN", _clientGstinCtrl),
                  _field("Address", _clientAddressCtrl),
                  _field("State", _clientStateCtrl),
                ],
              ),

              const SizedBox(height: 24),
              _itemsSection(),
              const SizedBox(height: 24),
              AmountSummary(items: items),
            ],
          ),
          _bottomSaveBar(),
        ],
      ),
    );
  }

  /* ---------------- DATE FIELD ---------------- */

  Widget _dateField({
    required String label,
    required DateTime value,
    required ValueChanged<DateTime> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: value,
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
          );
          if (picked != null) onChanged(picked);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            _formatDate(value),
            style: const TextStyle(fontSize: 15),
          ),
        ),
      ),
    );
  }

  /* ---------------- BOTTOM SAVE BAR ---------------- */

  Widget _bottomSaveBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade200),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _saving ? null : _createInvoice,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _saving
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Text(
              "Save Invoice",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /* ---------------- ITEMS ---------------- */

  Widget _itemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "ITEMS",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        ...items.asMap().entries.map(
              (e) => InvoiceItemCard(
            item: e.value,
            onRemove: () => setState(() => items.removeAt(e.key)),
            onChanged: () => setState(() {}),
          ),
        ),
        TextButton.icon(
          onPressed: () =>
              setState(() => items.add(InvoiceItemModel.empty())),
          icon: const Icon(Icons.add),
          label: const Text("Add Item"),
        ),
      ],
    );
  }

  /* ---------------- COMMON ---------------- */

  Widget _sectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF4F46E5),
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _field(
      String label,
      TextEditingController controller, {
        bool required = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: required ? "$label *" : label,
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}


