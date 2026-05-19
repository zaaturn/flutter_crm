import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShareMobileTopBar extends StatelessWidget {
  const ShareMobileTopBar({
    super.key,
    required this.title,
    required this.onBack,
  });

  final String title;
  final VoidCallback onBack;

  static const Color _bgScreen = Color(0xFFFEF7F1);
  static const Color _textMain = Color(0xFF1A1C1E);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.fromLTRB(8, 0, 20, 0),
      decoration: const BoxDecoration(
        color: _bgScreen,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: _textMain,
            splashRadius: 22,
          ),
          Text(
            title,
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              color: _textMain,
            ),
          ),
        ],
      ),
    );
  }
}