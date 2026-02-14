import 'package:flutter/material.dart';

import 'package:my_app/services/secure_storage_service.dart';
import 'package:my_app/billing/services/billing_api.dart';
import 'package:my_app/billing/models/company_model.dart';

import '../navigation/billing_flow_controller.dart';
import 'company_profile_screen.dart';

class ChooseCompanyScreen extends StatelessWidget {
  const ChooseCompanyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = SecureStorageService();
    const Color primaryIndigo = Color(0xFF4F46E5);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Select Company",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Color(0xFF1E293B),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _optionCard(
              icon: Icons.business_center_rounded,
              title: "Use Saved Company",
              subtitle: "Continue with your existing business profile",
              accentColor: primaryIndigo,
              onTap: () async {
                final token = await storage.readToken();
                if (token == null) {
                  _showSnack(context, "Authentication required");
                  return;
                }

                // 🔑 ALWAYS fetch from backend
                final companies = await BillingApi.getCompanies(token);

                if (companies.isEmpty) {
                  _showSnack(context, "No saved company found");
                  return;
                }

                if (!context.mounted) return;

                // ✅ Auto-select if only one company
                if (companies.length == 1) {
                  final company = companies.first;

                  if (company.id == null) {
                    _showSnack(context, "Invalid company or session");
                    return;
                  }

                  await storage.saveCompanyId(company.id!);

                  await BillingFlowController.goToCreateInvoice(
                    context,
                    companyId: company.id!,
                    authToken: token,
                  );
                  return;
                }

                // ✅ Multiple companies → let user pick
                _showCompanyPicker(
                  context,
                  companies,
                  onSelect: (company) async {
                    if (company.id == null) {
                      _showSnack(context, "Invalid company data");
                      return;
                    }

                    await storage.saveCompanyId(company.id!);

                    if (!context.mounted) return;
                    await BillingFlowController.goToCreateInvoice(
                      context,
                      companyId: company.id!,
                      authToken: token,
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            _optionCard(
              icon: Icons.add_business_rounded,
              title: "Add New Company",
              subtitle: "Create a fresh company profile to start billing",
              accentColor: const Color(0xFF0F172A),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CompanyProfileScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /* ================= UI HELPERS ================= */

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: const Color(0xFF1E293B),
      ),
    );
  }

  void _showCompanyPicker(
      BuildContext context,
      List<CompanyModel> companies, {
        required Function(CompanyModel) onSelect,
      }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Your Companies",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: companies.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final c = companies[i];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFF1F5F9)),
                      ),
                      tileColor: const Color(0xFFF8FAFC),
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFE0E7FF),
                        child: Icon(Icons.business_rounded, color: Color(0xFF4F46E5), size: 20),
                      ),
                      title: Text(
                        c.name,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                      onTap: () {
                        Navigator.pop(context);
                        onSelect(c);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _optionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, size: 28, color: accentColor),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFFCBD5E1)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}