import 'package:flutter/material.dart';
import 'package:my_app/billing/models/invoice_review_model.dart';

class InvoiceItemsCard extends StatelessWidget {
  final List<InvoiceItem> items;
  final double subtotal;
  final double taxTotal;
  final double grandTotal;

  const InvoiceItemsCard({
    super.key,
    required this.items,
    required this.subtotal,
    required this.taxTotal,
    required this.grandTotal,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryIndigo = Color(0xFF4F46E5);
    const Color neutralText = Color(0xFF111827);
    const Color mutedText = Color(0xFF6B7280);
    const Color surfaceGrey = Color(0xFFF9FAFB);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: primaryIndigo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.list_alt_rounded, size: 18, color: primaryIndigo),
                ),
                const SizedBox(width: 12),
                const Text(
                  "LINE ITEMS",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: mutedText,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF3F4F6)),

          // Item List Section
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final double lineTotal = item.lineTotal ?? (item.price * item.quantity);

              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: index == items.length - 1 ? Colors.transparent : const Color(0xFFF3F4F6),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.description,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: neutralText,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "₹${lineTotal.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: neutralText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          "Quantity: ${item.quantity.toInt()}",
                          style: const TextStyle(fontSize: 13, color: mutedText, fontWeight: FontWeight.w500),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: CircleAvatar(radius: 2, backgroundColor: Color(0xFFD1D5DB)),
                        ),
                        Text(
                          "Price: ₹${item.price.toStringAsFixed(2)}",
                          style: const TextStyle(fontSize: 13, color: mutedText, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          // Total Summary Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: surfaceGrey,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Column(
              children: [
                _buildSummaryLine("Subtotal", subtotal, isBold: false),
                const SizedBox(height: 12),
                _buildSummaryLine("Tax Total", taxTotal, isBold: false),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Divider(height: 1, color: Color(0xFFE5E7EB)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Amount Due",
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: neutralText),
                    ),
                    Text(
                      "₹${grandTotal.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        color: primaryIndigo,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryLine(String label, double value, {required bool isBold}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14, fontWeight: FontWeight.w500),
        ),
        Text(
          "₹${value.toStringAsFixed(2)}",
          style: TextStyle(
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w700,
            fontSize: 14,
            color: const Color(0xFF111827),
          ),
        ),
      ],
    );
  }
}