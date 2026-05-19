import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'client_tracker_mobile_theme.dart';

class ClientTrackerMobileTopBar extends StatelessWidget {
  const ClientTrackerMobileTopBar({
    super.key,
    required this.title,
    required this.onBack,
    this.trailing,
  });

  final String title;
  final VoidCallback onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.fromLTRB(8, 0, 12, 0),
      decoration: const BoxDecoration(
        color: Color(0xFFFAF9F6),
        border: Border(bottom: BorderSide(color: Color(0x1AE2E8F0))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: ClientTrackerMobileTheme.text,
            splashRadius: 22,
          ),
          Text(
            title,
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
              color: ClientTrackerMobileTheme.text,
            ),
          ),
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

