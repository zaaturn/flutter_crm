import 'package:flutter/material.dart';
import '../theme/billing_theme.dart';
import '../theme/billing_adaptive_theme.dart';

/// Large SaaS-style tappable card (billing hub, choose flow).
class BillingSaasActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color accent;

  const BillingSaasActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.accent = BillingTheme.purple,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BillingAdaptiveTheme.cardDecoration(context),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: BillingAdaptiveTheme.primaryLight(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: BillingAdaptiveTheme.border(context)),
                ),
                child: Icon(icon, size: 26, color: accent),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: BillingTheme.cardTitle().copyWith(
                        color: BillingAdaptiveTheme.text(context),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: BillingTheme.cardSubtitle().copyWith(
                        color: BillingAdaptiveTheme.muted(context),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: BillingAdaptiveTheme.primary(context).withValues(alpha: 0.7)),
            ],
          ),
        ),
      ),
    );
  }
}
