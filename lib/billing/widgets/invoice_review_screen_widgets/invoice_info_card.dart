import 'package:flutter/material.dart';

class InvoiceInfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String name;
  final String address;
  final String gst;
  final Color accentColor;

  const InvoiceInfoCard({
    super.key,
    required this.title,
    required this.icon,
    required this.name,
    required this.address,
    required this.gst,
    this.accentColor = const Color(0xFF4F46E5), // Indigo 600
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // More rounded for modern feel
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E1B4B).withOpacity(0.04), // Indigo-tinted shadow
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtle accent decoration in the corner
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [accentColor.withOpacity(0.05), Colors.transparent],
                ),
                borderRadius: const BorderRadius.only(topRight: Radius.circular(20)),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildName(),

                // Content section with soft divider
                if (address.isNotEmpty || gst.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Container(height: 1, color: const Color(0xFFF3F4F6)),
                  const SizedBox(height: 18),
                ],

                if (address.isNotEmpty) _buildInfoRow(Icons.map_outlined, address),
                if (address.isNotEmpty && gst.isNotEmpty) const SizedBox(height: 16),
                if (gst.isNotEmpty) _buildInfoRow(Icons.fingerprint_rounded, "GST $gst", isGst: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // Icon Badge
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accentColor, size: 18),
            ),
            const SizedBox(width: 12),
            Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.3,
                color: accentColor.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildName() {
    return Text(
      name.isEmpty ? 'N/A' : name,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFF111827),
        letterSpacing: -0.3,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildInfoRow(IconData iconData, String text, {bool isGst = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          child: Icon(iconData, size: 16, color: const Color(0xFF9CA3AF)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              fontWeight: isGst ? FontWeight.w600 : FontWeight.w400,
              color: isGst ? const Color(0xFF4B5563) : const Color(0xFF6B7280),
            ),
          ),
        ),
      ],
    );
  }
}