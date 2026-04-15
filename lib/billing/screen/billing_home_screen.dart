import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../navigation/billing_flow_controller.dart';
import '../theme/billing_theme.dart';
import '../widgets/billing_app_bar.dart';
import '../widgets/billing_saas_action_card.dart';

class BillingHomeScreen extends StatelessWidget {
  const BillingHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BillingTheme.scaffoldBg,
      appBar: billingAppBar(
        title: 'Billing',
        onBack: () => BillingFlowController.backToAdminDashboard(context),
      ),
      body: Stack(
        children: [
          Positioned(
            top: -80,
            right: -60,
            child: IgnorePointer(
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: BillingTheme.purple.withValues(alpha: 0.06),
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Finance', style: BillingTheme.overline()),
                    const SizedBox(height: 8),
                    Text('Invoices & PDFs', style: BillingTheme.titleLarge()),
                    const SizedBox(height: 8),
                    Text(
                      'Create drafts, issue invoices, and track payments by month.',
                      style: BillingTheme.body(),
                    ),
                    const SizedBox(height: 28),
                    BillingSaasActionCard(
                      icon: Icons.add_circle_outline_rounded,
                      title: 'Generate invoice',
                      subtitle: 'New draft with line items, dates, and PDF design.',
                      onTap: () => BillingFlowController.startGenerate(context),
                    ),
                    const SizedBox(height: 14),
                    BillingSaasActionCard(
                      icon: Icons.receipt_long_rounded,
                      title: 'Track invoices',
                      subtitle: 'Month view, payment status, issue, and PDF download.',
                      accent: BillingTheme.purpleDark,
                      onTap: () => BillingFlowController.startTrack(context),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
