import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/billing_adaptive_theme.dart';

class InvoiceSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const InvoiceSectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = BillingAdaptiveTheme.isMobile(context);

    return Container(
      decoration: isMobile
          ? BoxDecoration(
        color: const Color(0xFFFFFDFB), // Solid Paper White
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB14D1E).withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      )
          : BillingAdaptiveTheme.cardDecoration(context),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isMobile ? const Color(0xFFF5E6DA) : BillingAdaptiveTheme.primaryLight(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isMobile ? const Color(0xFFB14D1E).withOpacity(0.1) : BillingAdaptiveTheme.border(context),
                  ),
                ),
                child: Icon(
                  icon,
                  color: isMobile ? const Color(0xFFB14D1E) : BillingAdaptiveTheme.primary(context),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isMobile ? const Color(0xFF1A1C1E) : BillingAdaptiveTheme.text(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}