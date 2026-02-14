import 'package:flutter/material.dart';

class InvoiceSummaryCard extends StatelessWidget {
  final String status;
  final String? invoiceNumber;
  final double grandTotal;
  final DateTime invoiceDate;

  const InvoiceSummaryCard({
    super.key,
    required this.status,
    this.invoiceNumber,
    required this.grandTotal,
    required this.invoiceDate,
  });

  @override
  Widget build(BuildContext context) {
    // Logic check for status display
    final bool isDraft = status.toUpperCase() == "DRAFT";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4F46E5), // Indigo 600
            Color(0xFF3730A3), // Indigo 800
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background Glow Effect
          Positioned(
            right: -20,
            top: -20,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white.withOpacity(0.05),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= STATUS HEADER =================
                _buildDynamicStatusBadge(isDraft),

                const SizedBox(height: 32),

                // ================= MAIN CONTENT =================
                const Text(
                  "TOTAL AMOUNT",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        "₹",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        grandTotal.toStringAsFixed(2),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ================= FOOTER =================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Glass-style Date Container
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.event_note_rounded,
                              size: 14,
                              color: Colors.white.withOpacity(0.7)),
                          const SizedBox(width: 8),
                          Text(
                            _formatDate(invoiceDate),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // SaaS Decorative element
                    Icon(
                      Icons.auto_awesome_motion_rounded,
                      color: Colors.white.withOpacity(0.2),
                      size: 20,
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

  Widget _buildDynamicStatusBadge(bool isDraft) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDraft
            ? const Color(0xFFFBBF24).withOpacity(0.2) // Amber
            : const Color(0xFF34D399).withOpacity(0.2), // Emerald
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDraft
              ? const Color(0xFFFBBF24).withOpacity(0.4)
              : const Color(0xFF34D399).withOpacity(0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDraft ? const Color(0xFFFBBF24) : const Color(0xFF34D399),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isDraft ? "DRAFT" : "ISSUED",
            style: TextStyle(
              color: isDraft ? const Color(0xFFFEF3C7) : const Color(0xFFD1FAE5),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }
}