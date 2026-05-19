import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../theme/billing_theme.dart';
import '../../../theme/billing_adaptive_theme.dart';

class TemporalCard extends StatelessWidget {
  final DateTime invoiceDate;
  final DateTime dueDate;
  final ValueChanged<DateTime> onInvoiceChanged;
  final ValueChanged<DateTime> onDueChanged;

  const TemporalCard({
    super.key,
    required this.invoiceDate,
    required this.dueDate,
    required this.onInvoiceChanged,
    required this.onDueChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _dateField(
          context,
          label: 'Invoice date',
          value: invoiceDate,
          onPick: onInvoiceChanged,
        ),
        const SizedBox(height: 12),
        _dateField(
          context,
          label: 'Due date',
          value: dueDate,
          onPick: onDueChanged,
        ),
      ],
    );
  }

  Widget _dateField(
      BuildContext context, {
        required String label,
        required DateTime value,
        required ValueChanged<DateTime> onPick,
      }) {
    final fmt = DateFormat('dd MMM yyyy'); // Cleaner format for mobile
    final bool isMobile = BillingAdaptiveTheme.isMobile(context);

    // Zaaturn Mobile Constants
    const Color inkText = Color(0xFF1A1C1E);
    const Color accentOrange = Color(0xFFB14D1E);
    const Color clayFill = Color(0xFFF5E6DA);

    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime(2020, 1, 1),
          lastDate: DateTime(2100, 12, 31),
          builder: (ctx, child) =>
              Theme(data: BillingAdaptiveTheme.datePickerTheme(ctx), child: child!),
        );
        if (picked != null) onPick(picked);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isMobile ? clayFill : BillingTheme.scaffoldBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isMobile ? Colors.black.withOpacity(0.05) : BillingTheme.border,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      label.toUpperCase(),
                      style: isMobile
                          ? GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                        color: accentOrange,
                      )
                          : BillingTheme.overline()
                  ),
                  const SizedBox(height: 6),
                  Text(
                    fmt.format(value),
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isMobile ? inkText : BillingTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.calendar_today_rounded,
              color: isMobile ? accentOrange : BillingTheme.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}