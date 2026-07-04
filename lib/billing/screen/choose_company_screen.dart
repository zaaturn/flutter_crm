import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:my_app/services/secure_storage_service.dart';
import 'package:my_app/billing/services/billing_api.dart';
import 'package:my_app/billing/models/company_model.dart';

import '../navigation/billing_flow_controller.dart';
import '../theme/billing_theme.dart';
import '../theme/billing_leave_mobile_theme.dart';
import '../theme/billing_adaptive_theme.dart';
import '../widgets/billing_app_bar.dart';
import '../widgets/billing_saas_hero_card.dart';
import 'company_profile_screen.dart';

class ChooseCompanyScreen extends StatelessWidget {
  const ChooseCompanyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = SecureStorageService();

    return Scaffold(
      backgroundColor: BillingAdaptiveTheme.canvas(context),
      appBar: billingAppBar(
        title: 'Company',
        onBack: () => Navigator.of(context).maybePop(),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 840;


          final overlineStyle = wide ? BillingTheme.overline() : BillingLeaveMobileTheme.overline();
          final titleStyle = wide ? BillingTheme.titleLarge() : BillingLeaveMobileTheme.titleLarge();
          final bodyStyle = wide ? BillingTheme.body() : BillingLeaveMobileTheme.body();

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
                    Text('Billing setup', style: overlineStyle),
                    const SizedBox(height: 8),
                    Text('Choose company', style: titleStyle),
                    const SizedBox(height: 8),
                    Text(
                      'Continue with a saved business profile or create a new one.',
                      style: bodyStyle,
                    ),
                    const SizedBox(height: 28),
                    if (wide)
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: BillingSaasHeroCard(
                                height: 220,
                                icon: Icons.business_center_rounded,
                                title: 'Use saved company',
                                subtitle: 'Pick from your registered entities.',
                                onTap: () => _onSavedCompany(context, storage),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: BillingSaasHeroCard(
                                height: 220,
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
                        ),
                      )
                    else ...[
                      BillingSaasHeroCard(
                        icon: Icons.business_center_rounded,
                        title: 'Use saved company',
                        subtitle: 'Pick from your registered entities.',
                        height: 180,
                        decoration: BillingLeaveMobileTheme.cardDecoration().copyWith(
                          color: const Color(0xFFD1EBE5),
                          border: Border.all(color: Colors.black.withOpacity(0.05)),
                        ),
                        iconBackground: Colors.white.withOpacity(0.5),
                        iconBorderColor: Colors.transparent,
                        titleStyle: BillingLeaveMobileTheme.cardTitle().copyWith(
                          color: const Color(0xFF1A1C1E),
                          fontWeight: FontWeight.w900,
                        ),
                        subtitleStyle: BillingLeaveMobileTheme.cardSubtitle().copyWith(
                          color: const Color(0xFF1A1C1E).withOpacity(0.7),
                          fontWeight: FontWeight.w700,
                        ),
                        accent: const Color(0xFF1A1C1E),
                        onTap: () => _onSavedCompany(context, storage),
                      ),
                      const SizedBox(height: 16),
                      BillingSaasHeroCard(
                        icon: Icons.add_business_rounded,
                        title: 'Add new company',
                        subtitle: 'Company profile, bank, and branding.',
                        height: 180,
                        decoration: BillingLeaveMobileTheme.cardDecoration().copyWith(
                          color: const Color(0xFFE5E7FF),
                          border: Border.all(color: Colors.black.withOpacity(0.05)),
                        ),
                        iconBackground: Colors.white.withOpacity(0.5),
                        iconBorderColor: Colors.transparent,
                        titleStyle: BillingLeaveMobileTheme.cardTitle().copyWith(
                          color: const Color(0xFF1A1C1E),
                          fontWeight: FontWeight.w900,
                        ),
                        subtitleStyle: BillingLeaveMobileTheme.cardSubtitle().copyWith(
                          color: const Color(0xFF1A1C1E).withOpacity(0.7),
                          fontWeight: FontWeight.w700,
                        ),
                        accent: const Color(0xFF1A1C1E),
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
      if (!context.mounted) return;
      _showSnack(context, 'Authentication required');
      return;
    }
    final companies = await BillingApi.getCompanies(token);
    if (companies.isEmpty) {
      if (!context.mounted) return;
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
        backgroundColor: BillingLeaveMobileTheme.primary,
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
      backgroundColor: BillingAdaptiveTheme.bg(context), // Seamless sheet color
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: BillingLeaveMobileTheme.border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Your companies',
                style: BillingLeaveMobileTheme.cardTitle(),
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 420),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: companies.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final c = companies[i];
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: BillingLeaveMobileTheme.border),
                      ),
                      tileColor: BillingLeaveMobileTheme.surface,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: BillingLeaveMobileTheme.surfaceMuted,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.business_rounded,
                          color: BillingLeaveMobileTheme.accent,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        c.name,
                        style: BillingLeaveMobileTheme.cardTitle().copyWith(fontSize: 14),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
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