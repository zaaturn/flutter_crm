import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'package:my_app/services/secure_storage_service.dart';
import 'package:my_app/billing/services/billing_api.dart';
import 'package:my_app/billing/models/CompanyBankDetailsModel.dart';
import 'package:my_app/billing/widgets/currency_dropdown.dart';
import 'package:my_app/billing/widgets/company_upload_section.dart';
import 'package:my_app/billing/theme/billing_theme.dart';
import 'package:my_app/billing/theme/billing_adaptive_theme.dart';
import 'package:my_app/billing/widgets/billing_app_bar.dart';

class CompanyProfileScreen extends StatefulWidget {
  final bool redirectAfterSave;
  final bool fresh;

  const CompanyProfileScreen({
    super.key,
    this.redirectAfterSave = false,
    this.fresh = true,
  });

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  static const Color _bgScreen = Color(0xFFFEF7F1);
  static const Color _cardPaper = Color(0xFFFFFDFB);
  static const Color _clayFill = Color(0xFFF5E6DA);
  static const Color _accentOrange = Color(0xFFB14D1E);
  static const Color _inkText = Color(0xFF1A1C1E);

  final _formKey = GlobalKey<FormState>();
  final _storage = SecureStorageService();

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

  String _currency = "INR";
  bool _loading = true;
  bool _saving = false;
  bool _accountEditable = true;

  XFile? _logoFile;
  XFile? _signatureFile;
  String? _logoUrl;
  String? _signatureUrl;

  @override
  void initState() {
    super.initState();
    if (!widget.fresh) {
      _loadCompany();
    } else {
      _loading = false;
    }
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
          bankNameCtrl.text = company.bankDetails!.bankName;
          accountNumberCtrl.text = company.bankDetails!.accountNumberMasked ?? '';
          ifscCtrl.text = company.bankDetails!.ifscCode;
          upiCtrl.text = company.bankDetails!.upiId ?? '';
          _accountEditable = false;
        }
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _resetForm() {
    nameCtrl.clear();
    gstCtrl.clear();
    addressCtrl.clear();
    stateCtrl.clear();
    countryCtrl.text = "India";
    accountHolderCtrl.clear();
    bankNameCtrl.clear();
    accountNumberCtrl.clear();
    ifscCtrl.clear();
    upiCtrl.clear();
    _currency = "INR";
    _accountEditable = true;
    _logoFile = null;
    _signatureFile = null;
    setState(() {});
  }

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
        logoFile: _logoFile,
        signatureFile: _signatureFile,
      );
      if (company.id != null && _hasBankDetails()) {
        final bankDetails = CompanyBankDetailsModel(
          accountHolderName: accountHolderCtrl.text.trim().isEmpty ? null : accountHolderCtrl.text.trim(),
          bankName: bankNameCtrl.text.trim(),
          accountNumber: _accountEditable ? accountNumberCtrl.text.trim() : null,
          ifscCode: ifscCtrl.text.trim(),
          upiId: upiCtrl.text.trim().isEmpty ? null : upiCtrl.text.trim(),
        );
        await BillingApi.saveCompanyBank(token: token, companyId: company.id!, bank: bankDetails);
      }
      await _storage.saveCompanyId(company.id!);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) _showSnack('Failed to save: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? const Color(0xFFDC2626) : const Color(0xFF0C56D0),
      ),
    );
  }

  bool _hasBankDetails() {
    return accountHolderCtrl.text.trim().isNotEmpty ||
        bankNameCtrl.text.trim().isNotEmpty ||
        (_accountEditable && accountNumberCtrl.text.trim().isNotEmpty) ||
        ifscCtrl.text.trim().isNotEmpty ||
        upiCtrl.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 840;

    return Scaffold(
      backgroundColor: BillingAdaptiveTheme.bg(context),
      appBar: billingAppBar(
        title: 'Company Profile',
        onBack: () => Navigator.of(context).maybePop(),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0C56D0)))
          : Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.fromLTRB(wide ? 48 : 20, 24, wide ? 48 : 20, 32),
              children: [
                Text(
                  'Business Identity',
                  textAlign: wide ? TextAlign.start : TextAlign.center,
                  style: GoogleFonts.manrope(
                    fontSize: wide ? 32 : 28,
                    fontWeight: FontWeight.w900,
                    color: _inkText,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Configure your legal and financial details for invoice generation.',
                  textAlign: wide ? TextAlign.start : TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF74777F),
                  ),
                ),
                const SizedBox(height: 28),
                _sectionCard(
                  wide,
                  child: CompanyUploadsSection(
                    logoUrl: _logoFile?.path ?? _logoUrl,
                    signatureUrl: _signatureFile?.path ?? _signatureUrl,
                    onLogoChanged: (file) => setState(() => _logoFile = file),
                    onSignatureChanged: (file) => setState(() => _signatureFile = file),
                  ),
                ),
                _sectionHeader("Legal Identity"),
                _sectionCard(
                  wide,
                  child: Column(
                    children: [
                      _input(wide, nameCtrl, "Company Name", required: true),
                      _input(wide, gstCtrl, "GST / Tax Number"),
                    ],
                  ),
                ),
                _sectionHeader("Location"),
                _sectionCard(
                  wide,
                  child: Column(
                    children: [
                      _input(wide, addressCtrl, "Full Address", maxLines: 2),
                      _buildGrid(wide, [
                        _input(wide, stateCtrl, "State"),
                        _input(wide, countryCtrl, "Country"),
                      ]),
                    ],
                  ),
                ),
                _sectionHeader("Bank Details"),
                _sectionCard(
                  wide,
                  child: Column(
                    children: [
                      _buildGrid(wide, [
                        _input(wide, accountHolderCtrl, "Account Holder"),
                        _input(wide, bankNameCtrl, "Bank Name", required: true),
                      ]),
                      _buildGrid(wide, [
                        _input(wide, accountNumberCtrl, "Account Number",
                            enabled: _accountEditable, required: _accountEditable),
                        _input(wide, ifscCtrl, "IFSC Code"),
                      ]),
                      _input(wide, upiCtrl, "UPI ID"),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _saving ? null : _resetForm,
                      child: Text(
                        'Reset',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF74777F),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _saving ? null : _saveCompany,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: wide ? const Color(0xFF0C56D0) : const Color(0xFF8D5B39),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _saving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text('Save Profile', style: GoogleFonts.manrope(fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionCard(bool wide, {required Widget child}) {
    if (wide) {
      return Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BillingTheme.cardDecoration(),
        child: child,
      );
    }
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: _cardPaper,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: _accentOrange.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionHeader(String title) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 12, left: 4),
    child: Text(
      title.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.3,
        color: _accentOrange,
      ),
    ),
  );

  Widget _buildGrid(bool wide, List<Widget> children) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.map((w) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: w))).toList(),
    );
  }

  Widget _input(bool wide, TextEditingController ctrl, String label, {bool required = false, bool enabled = true, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        enabled: enabled,
        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: _inkText),
        validator: required ? (v) => v == null || v.isEmpty ? "Required" : null : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(color: const Color(0xFF74777F), fontSize: 12, fontWeight: FontWeight.w700),
          filled: true,
          fillColor: wide ? BillingAdaptiveTheme.bg(context) : _clayFill,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: wide ? BillingAdaptiveTheme.border(context) : _accentOrange.withOpacity(0.08)),
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
}