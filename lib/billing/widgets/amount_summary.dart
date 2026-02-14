import 'package:flutter/material.dart';
import '../models/invoice_item_model.dart';

class AmountSummary extends StatelessWidget {
  final List<InvoiceItemModel> items;

  const AmountSummary({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    double subtotal = 0;
    double taxAmount = 0;

    // Detect currency from the first item, or default to Rupees
    // This ensures that if the user selects $ in the card, the summary matches
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _summaryRow(
            label: "Subtotal",
            value: subtotal,
            symbol: currencySymbol,
          ),
          const SizedBox(height: 12),
          _summaryRow(
            label: "Tax Total",
            value: taxAmount,
            symbol: currencySymbol,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Grand Total",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              Text(
                "$currencySymbol ${total.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF4F46E5), // Indigo Highlight
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
    required String label,
    required double value,
    required String symbol,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
          ),
        ),
        Text(
          "$symbol ${value.toStringAsFixed(2)}",
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }
}
