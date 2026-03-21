import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatsRow extends StatelessWidget {
  final int working;
  final int onBreak;
  final int absent;

  const StatsRow({
    super.key,
    required this.working,
    required this.onBreak,
    required this.absent,
  });

  @override
  Widget build(BuildContext context) {

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _buildSaaSCard("Working", working, const Color(0xFF10B981)),
            const SizedBox(width: 12),
            _buildSaaSCard("Break", onBreak, const Color(0xFFF59E0B)),
            const SizedBox(width: 12),
            _buildSaaSCard("Absent", absent, const Color(0xFFEF4444)),
          ],
        ),
      ),
    );
  }

  Widget _buildSaaSCard(String title, int value, Color accentColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                value.toString(),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: accentColor,
                  letterSpacing: -1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}