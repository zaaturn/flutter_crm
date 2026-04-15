import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:my_app/services/secure_storage_service.dart';
import 'package:my_app/billing/services/billing_api.dart';
import 'package:my_app/billing/models/company_model.dart';

import '../navigation/billing_flow_controller.dart';
import '../theme/billing_theme.dart';
import '../widgets/billing_app_bar.dart';
import '../widgets/billing_saas_hero_card.dart';
import 'company_profile_screen.dart';

class ChooseCompanyScreen extends StatelessWidget {
  const ChooseCompanyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = SecureStorageService();

    return Scaffold(
      backgroundColor: BillingTheme.scaffoldBg,
      appBar: billingAppBar(
        title: 'Company',
        onBack: () => Navigator.of(context).maybePop(),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 840;
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: wide ? 48 : 20,
              vertical: wide ? 40 : 24,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Billing setup', style: BillingTheme.overline()),
                    const SizedBox(height: 8),
                    Text('Choose company', style: BillingTheme.titleLarge()),
                    const SizedBox(height: 8),
                    Text(
                      'Continue with a saved business profile or create a new one.',
                      style: BillingTheme.body(),
                    ),
                    const SizedBox(height: 28),
                    if (wide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: BillingSaasHeroCard(
                              icon: Icons.business_center_rounded,
                              title: 'Use saved company',
                              subtitle: 'Pick from your registered entities.',
                              onTap: () => _onSavedCompany(context, storage),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: BillingSaasHeroCard(
                              icon: Icons.add_business_rounded,
                              title: 'Add new company',
                              subtitle: 'Company profile, bank, and branding.',
                              accent: BillingTheme.purpleDark,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CompanyProfileScreen(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    else ...[
                      BillingSaasHeroCard(
                        icon: Icons.business_center_rounded,
                        title: 'Use saved company',
                        subtitle: 'Pick from your registered entities.',
                        onTap: () => _onSavedCompany(context, storage),
                      ),
                      const SizedBox(height: 16),
                      BillingSaasHeroCard(
                        icon: Icons.add_business_rounded,
                        title: 'Add new company',
                        subtitle: 'Company profile, bank, and branding.',
                        accent: BillingTheme.purpleDark,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CompanyProfileScreen(),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _onSavedCompany(BuildContext context, SecureStorageService storage) async {
    final token = await storage.readToken();
    if (token == null) {
      _showSnack(context, 'Authentication required');
      return;
    }
    final companies = await BillingApi.getCompanies(token);
    if (companies.isEmpty) {
      _showSnack(context, 'No saved company found');
      return;
    }
    if (!context.mounted) return;

    if (companies.length == 1) {
      final company = companies.first;
      if (company.id == null) {
        _showSnack(context, 'Invalid company or session');
        return;
      }
      await storage.saveCompanyId(company.id!);
      if (!context.mounted) return;
      await BillingFlowController.goToCreateInvoice(
        context,
        companyId: company.id!,
        authToken: token,
      );
      return;
    }

    _showCompanyPicker(
      context,
      companies,
      onSelect: (company) async {
        if (company.id == null) return;
        await storage.saveCompanyId(company.id!);
        if (!context.mounted) return;
        await BillingFlowController.goToCreateInvoice(
          context,
          companyId: company.id!,
          authToken: token,
        );
      },
    );
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: BillingTheme.purpleDark,
      ),
    );
  }

  void _showCompanyPicker(
    BuildContext context,
    List<CompanyModel> companies, {
    required void Function(CompanyModel) onSelect,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: BillingTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your companies', style: BillingTheme.cardTitle()),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 420),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: companies.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final c = companies[i];
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: BillingTheme.border),
                      ),
                      tileColor: BillingTheme.scaffoldBg,
                      leading: Icon(Icons.business_rounded, color: BillingTheme.purple),
                      title: Text(
                        c.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          color: BillingTheme.textPrimary,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.pop(ctx);
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
}
