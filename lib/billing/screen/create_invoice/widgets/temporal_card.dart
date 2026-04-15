import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../theme/billing_theme.dart';

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
    final fmt = DateFormat('MM/dd/yyyy');
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime(2020, 1, 1),
          lastDate: DateTime(2100, 12, 31),
          builder: (ctx, child) =>
              Theme(data: BillingTheme.datePickerTheme(ctx), child: child!),
        );
        if (picked != null) onPick(picked);
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: BillingTheme.scaffoldBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: BillingTheme.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label.toUpperCase(), style: BillingTheme.overline()),
                  const SizedBox(height: 6),
                  Text(
                    fmt.format(value),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: BillingTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.calendar_month_rounded, color: BillingTheme.textMuted),
          ],
        ),
      ),
    );
  }
}

