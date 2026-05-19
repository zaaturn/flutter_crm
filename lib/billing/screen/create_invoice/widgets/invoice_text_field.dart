import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/billing_theme.dart';
import '../../../theme/billing_adaptive_theme.dart';

class InvoiceTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool requiredField;
  final int maxLines;
  final TextInputType? keyboardType;
  final Color? fillColor; // Added to fix the 'named parameter' error

  const InvoiceTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.requiredField = false,
    this.maxLines = 1,
    this.keyboardType,
    this.fillColor, // Receive the color from CreateInvoiceScreen
  });

  @override
  Widget build(BuildContext context) {
    final bool isMobile = BillingAdaptiveTheme.isMobile(context);

    // Zaaturn Mobile Constants
    const Color inkText = Color(0xFF1A1C1E);
    const Color accentOrange = Color(0xFFB14D1E);
    const Color clayFill = Color(0xFFF5E6DA);

    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: isMobile ? inkText : BillingTheme.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: requiredField ? '$label *' : label,
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isMobile ? const Color(0xFF74777F) : BillingTheme.textMuted,
        ),
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          color: const Color(0xFF74777F).withOpacity(0.5),
          fontSize: 13,
        ),
        filled: true,
        // Uses the color passed from parent, or defaults based on platform
        fillColor: fillColor ?? (isMobile ? clayFill : BillingTheme.scaffoldBg),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isMobile ? Colors.black.withOpacity(0.05) : BillingTheme.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isMobile ? accentOrange : BillingTheme.purple,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}