import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../navigation/billing_flow_controller.dart';
import '../theme/billing_theme.dart';
import '../theme/billing_adaptive_theme.dart';
import '../widgets/billing_app_bar.dart';
import '../widgets/billing_saas_action_card.dart';

class BillingHomeScreen extends StatelessWidget {
  const BillingHomeScreen({super.key});

  static const Color _purpleBox = Color(0xFFD1D5FF);
  static const Color _blueBox = Color(0xFF64B5F6);
  static const Color _inkText = Color(0xFF1A1C1E);

  @override
  Widget build(BuildContext context) {
    final bool isMobile = BillingAdaptiveTheme.isMobile(context);

    return Scaffold(
      backgroundColor: BillingAdaptiveTheme.bg(context),
      appBar: billingAppBar(
        title: 'Billing',
        onBack: () => BillingFlowController.backToAdminDashboard(context),
      ),
      body: Stack(
        children: [
          if (!isMobile)
            Positioned(
              top: -80,
              right: -60,
              child: IgnorePointer(
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: BillingAdaptiveTheme.primary(context).withOpacity(0.06),
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
                    Text(
                      'Finance',
                      style: isMobile
                          ? GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFB14D1E),
                        letterSpacing: 1.2,
                      )
                          : BillingTheme.overline(),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Invoices & PDFs',
                      style: BillingTheme.titleLarge().copyWith(
                        color: _inkText,
                        fontSize: isMobile ? 28 : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create drafts, issue invoices, and track payments by month.',
                      style: BillingTheme.body().copyWith(
                        color: const Color(0xFF74777F),
                      ),
                    ),
                    const SizedBox(height: 28),

                    if (isMobile) ...[
                      Row(
                        children: [
                          Expanded(
                            child: _VividCard(
                              color: _purpleBox,
                              icon: Icons.add_rounded,
                              title: 'Generate',
                              subtitle: 'New Invoice',
                              onTap: () => BillingFlowController.startGenerate(context),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _VividCard(
                              color: _blueBox,
                              icon: Icons.receipt_long_rounded,
                              title: 'Track',
                              subtitle: 'Invoice',
                              onTap: () => BillingFlowController.startTrack(context),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
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
                        accent: BillingAdaptiveTheme.primaryDark(context),
                        onTap: () => BillingFlowController.startTrack(context),
                      ),
                    ],
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

class _VividCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _VividCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 180,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.black87, size: 24),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}