import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/services/secure_storage_service.dart';
import 'package:my_app/billing/services/billing_api.dart';
import 'package:my_app/billing/models/CompanyBankDetailsModel.dart';
import 'package:my_app/billing/widgets/currency_dropdown.dart';
import 'package:my_app/billing/widgets/company_upload_section.dart';
import 'package:my_app/billing/theme/billing_theme.dart';
import 'package:my_app/billing/widgets/billing_app_bar.dart';
import 'package:google_fonts/google_fonts.dart';

class CompanyProfileScreen extends StatefulWidget {
  final bool redirectAfterSave;
  final bool fresh;

  /// `fresh=true` opens an empty form (no previous data).
  /// Set `fresh=false` to load existing company profile for edit.
  const CompanyProfileScreen({
    super.key,
    this.redirectAfterSave = false,
    this.fresh = true,
  });

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
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
    _resetForm();
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
    _logoUrl = null;
    _signatureUrl = null;
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
      _showSnack("Company profile saved successfully", isError: false);
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
        backgroundColor: isError ? const Color(0xFFDC2626) : BillingTheme.purple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
    return Scaffold(
      backgroundColor: BillingTheme.scaffoldBg,
      appBar: billingAppBar(
        title: 'Add new company',
        onBack: () => Navigator.of(context).maybePop(),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: BillingTheme.purple))
          : Stack(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  children: [
                    const SizedBox(height: 6),
                    Text(
                      'Company Settings',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: BillingTheme.textPrimary,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Configure your business identity and regional preferences. This information will appear on all issued invoices and legal documents.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: BillingTheme.textMuted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 26),

                    _whiteCard(
                      child: CompanyUploadsSection(
                        logoUrl: _logoFile?.path ?? _logoUrl,
                        signatureUrl: _signatureFile?.path ?? _signatureUrl,
                        onLogoChanged: (file) => setState(() => _logoFile = file),
                        onSignatureChanged: (file) => setState(() => _signatureFile = file),
                      ),
                    ),

                    _sectionHeader("Entity Identity"),
                    _whiteCard(
                      child: Column(
                        children: [
                          _input(nameCtrl, "Legal Company Name", required: true),
                          _input(gstCtrl, "Tax Identification / GST"),
                        ],
                      ),
                    ),

                    _sectionHeader("Operational Reach"),
                    _whiteCard(
                      child: Column(
                        children: [
                          _input(
                            addressCtrl,
                            "Physical Headquarters",
                            maxLines: 2,
                            leading: Icons.location_on_outlined,
                          ),
                          _buildFieldGrid([
                            _input(stateCtrl, "Jurisdiction / State"),
                            _input(countryCtrl, "Country"),
                          ]),
                        ],
                      ),
                    ),

                    _sectionHeader("Regional Settings"),
                    _whiteCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CurrencyDropdown(
                            value: _currency,
                            onChanged: (v) => setState(() => _currency = v),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              'This currency will be used by default for all new invoices and reporting metrics.',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: BillingTheme.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    _sectionHeader("Bank payment details"),
                    _whiteCard(
                      child: Column(
                        children: [
                          _buildFieldGrid([
                            _input(accountHolderCtrl, "Account holder name"),
                            _input(bankNameCtrl, "Bank name", required: true),
                          ]),
                          _buildFieldGrid([
                            _input(
                              accountNumberCtrl,
                              "Account number",
                              required: _accountEditable,
                              enabled: _accountEditable,
                            ),
                            _input(ifscCtrl, "IFSC code"),
                          ]),
                          _input(upiCtrl, "UPI ID"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),
                    const Divider(height: 1, color: BillingTheme.border),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _saving ? null : () {
                            _resetForm();
                            setState(() {});
                          },
                          child: Text(
                            'Discard changes',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              color: BillingTheme.textMuted,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _saving ? null : _saveCompany,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: BillingTheme.purple,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: _saving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  'Save company',
                                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900),
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _whiteCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: BillingTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BillingTheme.border),
        boxShadow: [
          BoxShadow(
            color: BillingTheme.purple.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.only(top: 26, bottom: 14),
        child: Text(
          title.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.3,
            color: BillingTheme.purple,
          ),
        ),
      );

  Widget _buildFieldGrid(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children
            .map(
              (w) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: w,
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _input(
    TextEditingController ctrl,
    String label, {
    bool required = false,
    bool enabled = true,
    int maxLines = 1,
    IconData? leading,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        enabled: enabled,
        style: const TextStyle(color: BillingTheme.textPrimary, fontSize: 14),
        validator: required ? (v) => v == null || v.isEmpty ? "Entry Required" : null : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: leading == null ? null : Icon(leading, color: BillingTheme.textMuted),
          labelStyle: const TextStyle(color: BillingTheme.textMuted, fontSize: 12),
          filled: true,
          fillColor: BillingTheme.scaffoldBg,
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
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDC2626)),
          ),
        ),
      ),
    );
  }
}