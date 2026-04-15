import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/billing_theme.dart';

class InvoiceTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool requiredField;
  final int maxLines;
  final TextInputType? keyboardType;

  const InvoiceTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.requiredField = false,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w600,
        color: BillingTheme.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: requiredField ? '$label *' : label,
        hintText: hint,
        filled: true,
        fillColor: BillingTheme.scaffoldBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: BillingTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: BillingTheme.purple, width: 1.5),
        ),
      ),
    );
  }
}

