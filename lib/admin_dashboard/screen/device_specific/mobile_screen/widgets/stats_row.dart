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
            _buildColorCard(
              title: "Working",
              value: working,
              bgColor: const Color(0xFF1D5603), // Lincoln Green Bg
              textColor: const Color(0xFFC3F380), // Lincoln Green Text
            ),
            const SizedBox(width: 10),
            _buildColorCard(
              title: "Break",
              value: onBreak,
              bgColor: const Color(0xFFC3F380), // Light Lime Bg
              textColor: const Color(0xFF7523B4), // Light Lime Text
            ),
            const SizedBox(width: 10),
            _buildColorCard(
              title: "Log Out",
              value: absent,
              bgColor: const Color(0xFFD13F13), // Brilliant Rose Bg
              textColor: const Color(0xFFFCC5C6), // Brilliant Rose Text
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorCard({
    required String title,
    required int value,
    required Color bgColor,
    required Color textColor,
  }) {
    const borderColor = Color(0xFF0F172A);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: borderColor,
            width: 1.75,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title.toUpperCase(),
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: textColor,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              value.toString(),
              style: GoogleFonts.manrope(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: textColor,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}