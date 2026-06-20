import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class Header extends StatelessWidget {
  final int totalEmployees;
  final int loggedInToday;
  final bool searchOpen;
  final TextEditingController searchController;
  final Animation<double> searchWidth;
  final VoidCallback onSearchToggle;

  const Header({
    super.key,
    required this.totalEmployees,
    required this.loggedInToday,
    required this.searchOpen,
    required this.searchController,
    required this.searchWidth,
    required this.onSearchToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Live Attendance",
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.5,
                      decoration: TextDecoration.none,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$totalEmployees Total · $loggedInToday logged in today',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
              ),

            ),
          ],
        ),
      ),
    );
  }}