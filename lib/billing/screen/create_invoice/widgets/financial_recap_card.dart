import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../theme/billing_theme.dart';

class FinancialRecapCard extends StatelessWidget {
  final double subtotal;
  final double taxTotal;
  final double grandTotal;

  const FinancialRecapCard({
    super.key,
    required this.subtotal,
    required this.taxTotal,
    required this.grandTotal,
  });

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    return Container(
      decoration: BillingTheme.cardDecoration(),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Financial recap', style: BillingTheme.cardTitle()),
          const SizedBox(height: 14),
          _line('Subtotal', money.format(subtotal)),
          const SizedBox(height: 8),
          _line('Tax', money.format(taxTotal)),
          const SizedBox(height: 14),
          const Divider(height: 1, color: BillingTheme.border),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Grand total'.toUpperCase(),
                  style: BillingTheme.overline().copyWith(color: BillingTheme.textMuted),
                ),
              ),
              Text(
                money.format(grandTotal),
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: BillingTheme.purpleDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: BillingTheme.purpleLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: BillingTheme.border),
            ),
            child: Text(
              'Ready to save? Review entities and ledger lines before dispatching.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: BillingTheme.purpleDark,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: BillingTheme.textMuted,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: BillingTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

