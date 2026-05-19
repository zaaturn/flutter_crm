import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/company_model.dart';
import '../theme/billing_adaptive_theme.dart';

class BillingFromDropdown extends StatelessWidget {
  final List<CompanyModel> companies;
  final CompanyModel? selected;
  final ValueChanged<CompanyModel> onChanged;

  const BillingFromDropdown({
    super.key,
    required this.companies,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (companies.isEmpty) return const SizedBox();

    final bool isMobile = BillingAdaptiveTheme.isMobile(context);

    const Color inkText = Color(0xFF1A1C1E);
    const Color accentOrange = Color(0xFFB14D1E);
    const Color clayFill = Color(0xFFF5E6DA);
    const Color paperWhite = Color(0xFFFFFDFB);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: isMobile
          ? BoxDecoration(
        color: paperWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: accentOrange.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      )
          : BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "BILLING FROM",
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: isMobile ? accentOrange : const Color(0xFF64748B),
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 12),

          if (companies.length == 1)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isMobile ? clayFill : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                companies.first.name.toUpperCase(),
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: inkText,
                  letterSpacing: 0.5,
                ),
              ),
            )
          else
            DropdownButtonFormField<CompanyModel>(
              value: selected,
              isExpanded: true,
              dropdownColor: isMobile ? paperWhite : Colors.white,
              icon: Icon(Icons.expand_more_rounded, color: isMobile ? accentOrange : null),
              items: companies.map((c) {
                return DropdownMenuItem(
                  value: c,
                  child: Text(
                    c.name,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      color: inkText,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (c) {
                if (c != null) onChanged(c);
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: isMobile ? clayFill : const Color(0xFFF9FAFB),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: isMobile ? Colors.transparent : const Color(0xFFE2E8F0),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}