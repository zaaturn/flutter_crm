import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:my_app/services/secure_storage_service.dart';
import 'package:my_app/billing/services/billing_api.dart';
import 'package:my_app/billing/models/CompanyBankDetailsModel.dart';

import 'package:my_app/billing/widgets/sticky_save_bar.dart';
import 'package:my_app/billing/widgets/currency_dropdown.dart';
import 'package:my_app/billing/widgets/company_upload_section.dart';

class CompanyProfileScreen extends StatefulWidget {
  final bool redirectAfterSave;
  const CompanyProfileScreen({super.key, this.redirectAfterSave = false});

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storage = SecureStorageService();
  final _picker = ImagePicker();

  // Controllers
  final nameCtrl = TextEditingController();
  final gstCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final stateCtrl = TextEditingController();
  final countryCtrl = TextEditingController(text: "India");

  final accountHolderCtrl = TextEditingController();
  final bankNameCtrl = TextEditingController();
  final accountNumberCtrl = TextEditingController();
  final ifscCtrl = TextEditingController();
  final upiCtrl = TextEditingController();

  // State
  String _currency = "INR";
  bool _loading = true;
  bool _saving = false;
  bool _accountEditable = true;

  // Uploads
  File? _logoFile;
  File? _signatureFile;
  String? _logoUrl;
  String? _signatureUrl;

  @override
  void initState() {
    super.initState();
    _loadCompany();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    gstCtrl.dispose();
    addressCtrl.dispose();
    stateCtrl.dispose();
    countryCtrl.dispose();
    accountHolderCtrl.dispose();
    bankNameCtrl.dispose();
    accountNumberCtrl.dispose();
    ifscCtrl.dispose();
    upiCtrl.dispose();
    super.dispose();
  }

  /* ---------------- LOAD COMPANY ---------------- */

  Future<void> _loadCompany() async {
    try {
      final token = await _storage.readToken();
      if (token == null) return;

      final company = await BillingApi.getCompanyProfile(token);
      if (company != null) {
        nameCtrl.text = company.name;
        gstCtrl.text = company.gstNumber;
        addressCtrl.text = company.address['full_address']?.toString() ?? '';
        stateCtrl.text = company.state;
        countryCtrl.text = company.country;
        _currency = company.currency;

        _logoUrl = company.logoUrl;
        _signatureUrl = company.signatureUrl;

        if (company.bankDetails != null) {
          accountHolderCtrl.text = company.bankDetails!.accountHolderName ?? '';
          bankNameCtrl.text = company.bankDetails!.bankName ?? '';
          accountNumberCtrl.text =
              company.bankDetails!.accountNumberMasked ?? '';
          ifscCtrl.text = company.bankDetails!.ifscCode ?? '';
          upiCtrl.text = company.bankDetails!.upiId ?? '';
          _accountEditable = false;
        }
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /* ---------------- SAVE COMPANY ---------------- */

  Future<void> _saveCompany() async {
    if (!_formKey.currentState!.validate()) return;
    if (_saving) return;

    setState(() => _saving = true);

    try {
      final token = await _storage.readToken();
      if (token == null) return;

      final company = await BillingApi.createOrUpdateCompany(
        token,
        {
          "name": nameCtrl.text.trim(),
          "gst_number": gstCtrl.text.trim(),
          "address": {"full_address": addressCtrl.text.trim()},
          "state": stateCtrl.text.trim(),
          "country": countryCtrl.text.trim(),
          "currency": _currency,
        },
        logoPath: _logoFile?.path,
        signaturePath: _signatureFile?.path,
      );

      if (company.id != null && _hasBankDetails()) {
        final bankDetails = CompanyBankDetailsModel(
          accountHolderName: accountHolderCtrl.text.trim().isEmpty
              ? null
              : accountHolderCtrl.text.trim(),
          bankName: bankNameCtrl.text.trim(),
          accountNumber: _accountEditable
              ? accountNumberCtrl.text.trim()
              : null,
          ifscCode: ifscCtrl.text.trim(),
          upiId:
          upiCtrl.text.trim().isEmpty ? null : upiCtrl.text.trim(),
        );

        await BillingApi.saveCompanyBank(
          token: token,
          companyId: company.id!,
          bank: bankDetails,
        );
      }

      // 🔑 SAVE COMPANY ID (CRITICAL)
      await _storage.saveCompanyId(company.id!);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Company profile saved successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // ✅ ONLY FIX: ALWAYS POP — NEVER NAVIGATE
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  bool _hasBankDetails() {
    return accountHolderCtrl.text.trim().isNotEmpty ||
        bankNameCtrl.text.trim().isNotEmpty ||
        (_accountEditable && accountNumberCtrl.text.trim().isNotEmpty) ||
        ifscCtrl.text.trim().isNotEmpty ||
        upiCtrl.text.trim().isNotEmpty;
  }

  /* ---------------- UI ---------------- */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Company Profile",
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          Form(
            key: _formKey,
            child: ListView(
              padding:
              const EdgeInsets.fromLTRB(24, 16, 24, 140),
              children: [
                CompanyUploadsSection(
                  logoUrl: _logoFile?.path ?? _logoUrl,
                  signatureUrl:
                  _signatureFile?.path ?? _signatureUrl,
                  onLogoChanged: (path) =>
                      setState(() => _logoFile = File(path)),
                  onSignatureChanged: (path) =>
                      setState(() => _signatureFile = File(path)),
                ),

                _section("Business Information"),
                _input(nameCtrl, "Company Name", required: true),
                _input(gstCtrl, "GST / Tax Number"),

                const SizedBox(height: 30),
                _section("Operations"),
                _input(addressCtrl, "Office Address", maxLines: 2),
                _input(stateCtrl, "State"),
                _input(countryCtrl, "Country"),

                const SizedBox(height: 16),
                CurrencyDropdown(
                  value: _currency,
                  onChanged: (v) =>
                      setState(() => _currency = v),
                ),

                const SizedBox(height: 40),
                _section("Bank & Payment Details"),
                _input(accountHolderCtrl, "Account Holder Name"),
                _input(bankNameCtrl, "Bank Name", required: true),
                _input(
                  accountNumberCtrl,
                  "Account Number",
                  required: _accountEditable,
                  enabled: _accountEditable,
                ),
                _input(ifscCtrl, "IFSC Code"),
                _input(upiCtrl, "UPI ID"),
              ],
            ),
          ),
          StickySaveBar(
            loading: _saving,
            onSave: _saveCompany,
          ),
        ],
      ),
    );
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        letterSpacing: 1.4,
        fontWeight: FontWeight.w700,
        color: Color(0xFF64748B),
      ),
    ),
  );

  Widget _input(
      TextEditingController ctrl,
      String label, {
        bool required = false,
        bool enabled = true,
        int maxLines = 1,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        enabled: enabled,
        validator:
        required ? (v) => v == null || v.isEmpty ? "Required" : null : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

