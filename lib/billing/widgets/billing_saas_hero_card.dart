import 'package:flutter/material.dart';
import '../theme/billing_theme.dart';

/// Tall centered card for “choose company” style layouts (SaaS).
class BillingSaasHeroCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color accent;

  const BillingSaasHeroCard({
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
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
          decoration: BillingTheme.cardDecoration(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  color: BillingTheme.purpleLight,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: BillingTheme.border),
                ),
                child: Icon(icon, size: 30, color: accent),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: BillingTheme.cardTitle().copyWith(fontSize: 15),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: BillingTheme.cardSubtitle(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
