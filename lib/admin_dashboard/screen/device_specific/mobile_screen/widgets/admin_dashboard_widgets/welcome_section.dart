import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/admin_dashboard/model/employee.dart';


class WelcomeSection extends StatelessWidget {
  final String firstName;
  final String lastName;

  const WelcomeSection({
    super.key,
    required this.firstName,
    required this.lastName,
  });

  @override
  Widget build(BuildContext context) {
    // SaaS Design Tokens
    const primaryIndigo = Color(0xFF6366F1);
    const slateDark = Color(0xFF0F172A);
    const slateMuted = Color(0xFF64748B);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          'WELCOME BACK',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            color: primaryIndigo.withOpacity(0.8),
          ),
        ),

        const SizedBox(height: 8),


        Text(
          '$firstName $lastName'.trim(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: slateDark,
            height: 1.1,
            letterSpacing: -0.8,
          ),
        ),

        const SizedBox(height: 10),

        // Workspace Subtext
        Text(
          'Manage your workspace efficiently.',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: slateMuted,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}