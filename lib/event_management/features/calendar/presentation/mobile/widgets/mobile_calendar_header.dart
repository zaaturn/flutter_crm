import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../mobile_calendar_theme.dart';

class MobileCalendarHeader extends StatelessWidget {
  const MobileCalendarHeader({
    super.key,
    required this.focusedMonth,
    required this.subtitle,
    required this.onToday,
    required this.onPrevious,
    required this.onNext,
    this.onBack,
  });

  final DateTime focusedMonth;
  final String subtitle;
  final VoidCallback onToday;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final month = DateFormat('MMMM').format(focusedMonth);
    final year = focusedMonth.year.toString();

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (onBack != null)
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  color: MobileCalendarTheme.textDark,
                ),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      '$month ',
                      style: GoogleFonts.manrope(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: MobileCalendarTheme.textDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      year,
                      style: GoogleFonts.manrope(
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                        color: MobileCalendarTheme.textMuted,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              _pillButton('Today', onToday),
              const SizedBox(width: 6),
              _circleNav(Icons.chevron_left_rounded, onPrevious),
              const SizedBox(width: 4),
              _circleNav(Icons.chevron_right_rounded, onNext),
            ],
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(onBack != null ? 48 : 16, 0, 16, 0),
            child: Text(
              subtitle,
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: MobileCalendarTheme.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pillButton(String label, VoidCallback onTap) {
    return Material(
      color: MobileCalendarTheme.card,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: MobileCalendarTheme.border),
          ),
          child: Text(
            label,
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              color: MobileCalendarTheme.textDark,
            ),
          ),
        ),
      ),
    );
  }

  Widget _circleNav(IconData icon, VoidCallback onTap) {
    return Material(
      color: MobileCalendarTheme.card,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: MobileCalendarTheme.border),
          ),
          child: Icon(icon, size: 22, color: MobileCalendarTheme.textDark),
        ),
      ),
    );
  }
}
