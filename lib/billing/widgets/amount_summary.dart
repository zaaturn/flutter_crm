import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/invoice_item_model.dart';

class AmountSummary extends StatelessWidget {
  final List<InvoiceItemModel> items;

  const AmountSummary({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 840;

    // Zaaturn Mobile Palette
    const Color inkText = Color(0xFF1A1C1E);
    const Color accentOrange = Color(0xFFB14D1E);
    const Color deepInk = Color(0xFF8D5B39);

    double subtotal = 0;
    double taxAmount = 0;

    String currencySymbol = items.isNotEmpty ? (items.first.currency ?? "₹") : "₹";

    for (var item in items) {
      final line = item.quantity * item.unitPrice;
      subtotal += line;
      taxAmount += line * (item.taxRate / 100);
    }

    final total = subtotal + taxAmount;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: wide ? Colors.white : const Color(0xFFFFFDFB), // Paper White for Mobile
        borderRadius: BorderRadius.circular(wide ? 16 : 24),
        border: Border.all(color: wide ? const Color(0xFFE5E7EB) : Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: wide ? Colors.black.withOpacity(0.02) : accentOrange.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _summaryRow(
            wide: wide,
            label: "Subtotal",
            value: subtotal,
            symbol: currencySymbol,
            inkColor: inkText,
          ),
          const SizedBox(height: 12),
          _summaryRow(
            wide: wide,
            label: "Tax Total",
            value: taxAmount,
            symbol: currencySymbol,
            inkColor: inkText,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(
              height: 1,
              thickness: 1,
              color: wide ? const Color(0xFFF3F4F6) : Colors.black.withOpacity(0.03),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Grand Total",
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: wide ? const Color(0xFF111827) : inkText,
                ),
              ),
              Text(
                "$currencySymbol ${total.toStringAsFixed(2)}",
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: wide ? const Color(0xFF4F46E5) : deepInk, // Zaaturn Deep Ink on Mobile
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow({
    required bool wide,
    required String label,
    required double value,
    required String symbol,
    required Color inkColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: wide ? const Color(0xFF6B7280) : inkColor.withOpacity(0.6),
          ),
        ),
        Text(
          "$symbol ${value.toStringAsFixed(2)}",
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: wide ? const Color(0xFF1F2937) : inkColor,
          ),
        ),
      ],
    );
  }
}