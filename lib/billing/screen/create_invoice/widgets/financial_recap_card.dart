import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../theme/billing_theme.dart';
import '../../../theme/billing_adaptive_theme.dart';

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
    final bool isMobile = BillingAdaptiveTheme.isMobile(context);
    final money = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

    // Zaaturn Mobile Constants
    const Color inkText = Color(0xFF1A1C1E);
    const Color accentOrange = Color(0xFFB14D1E);
    const Color clayFill = Color(0xFFF5E6DA);
    const Color paperWhite = Color(0xFFFFFDFB);
    const Color deepInk = Color(0xFF8D5B39);

    return Container(
      decoration: isMobile
          ? BoxDecoration(
        color: paperWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: accentOrange.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      )
          : BillingTheme.cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Financial Recap',
            style: isMobile
                ? GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: inkText,
            )
                : BillingTheme.cardTitle(),
          ),
          const SizedBox(height: 16),
          _line(isMobile, 'Subtotal', money.format(subtotal), inkText),
          const SizedBox(height: 10),
          _line(isMobile, 'Tax Amount', money.format(taxTotal), inkText),
          const SizedBox(height: 16),
          Divider(
            height: 1,
            color: isMobile ? Colors.black.withOpacity(0.05) : BillingTheme.border,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'GRAND TOTAL',
                  style: isMobile
                      ? GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: accentOrange,
                  )
                      : BillingTheme.overline().copyWith(color: BillingTheme.textMuted),
                ),
              ),
              Text(
                money.format(grandTotal),
                style: GoogleFonts.manrope(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: isMobile ? deepInk : BillingTheme.purpleDark,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isMobile ? clayFill : BillingTheme.purpleLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isMobile ? accentOrange.withOpacity(0.1) : BillingTheme.border,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: isMobile ? accentOrange : BillingTheme.purpleDark,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Review all entities and ledger lines before saving.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isMobile ? inkText.withOpacity(0.7) : BillingTheme.purpleDark,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(bool isMobile, String label, String value, Color ink) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isMobile ? ink.withOpacity(0.5) : BillingTheme.textMuted,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: isMobile ? ink : BillingTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}