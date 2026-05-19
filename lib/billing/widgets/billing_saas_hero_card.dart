import 'package:flutter/material.dart';
import '../theme/billing_theme.dart';

/// Tall centered card for “choose company” style layouts (SaaS).
class BillingSaasHeroCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color accent;
  final double? height;

  /// Optional overrides (used for mobile leave-themed billing).
  final BoxDecoration? decoration;
  final Color? iconBackground;
  final Color? iconBorderColor;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  const BillingSaasHeroCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.accent = BillingTheme.purple,
    this.height,
    this.decoration,
    this.iconBackground,
    this.iconBorderColor,
    this.titleStyle,
    this.subtitleStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          constraints: height == null
              ? null
              : BoxConstraints(
                  minHeight: height!,
                  maxHeight: height!,
                ),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          decoration: decoration ?? BillingTheme.cardDecoration(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  color: iconBackground ?? BillingTheme.purpleLight,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: iconBorderColor ?? BillingTheme.border),
                ),
                child: Icon(icon, size: 30, color: accent),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: (titleStyle ?? BillingTheme.cardTitle()).copyWith(fontSize: 15),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: subtitleStyle ?? BillingTheme.cardSubtitle(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
