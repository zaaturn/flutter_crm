import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/event_management/shared/themes/event_adaptive_theme.dart';

class CalendarMobileTopBar extends StatelessWidget {
  const CalendarMobileTopBar({
    super.key,
    required this.title,
    this.onBack,
    this.showBack = true,
  });

  final String title;
  final VoidCallback? onBack;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: EventAdaptiveTheme.header(context),
        border: Border(
          bottom: BorderSide(color: EventAdaptiveTheme.border(context).withValues(alpha: 0.7)),
        ),
      ),
      child: Row(
        children: [
          if (showBack)
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            )
          else
            const SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: EventAdaptiveTheme.text(context),
            ),
          ),
        ],
      ),
    );
  }
}

