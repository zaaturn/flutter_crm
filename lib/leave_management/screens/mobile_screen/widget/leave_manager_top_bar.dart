import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LeaveManagerTopBar extends StatelessWidget {
  const LeaveManagerTopBar({
    super.key,
    required this.onBack,
  });

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(

      height: 64,
      padding: const EdgeInsets.fromLTRB(8, 0, 20, 0),

      decoration: const BoxDecoration(
        color: Color(0xFFFFF7E8),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: Colors.black,
            splashRadius: 22,
          ),
          Text(
            'LeaveManager',
            style: GoogleFonts.manrope(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}