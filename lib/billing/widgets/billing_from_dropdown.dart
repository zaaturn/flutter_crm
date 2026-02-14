import 'package:flutter/material.dart';
import '../models/company_model.dart';

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

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "BILLING FROM",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 8),

          // 🔹 Single company → text only
          if (companies.length == 1)
            Text(
              companies.first.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            )

          // 🔹 Multiple companies → dropdown
          else
            DropdownButtonFormField<CompanyModel>(
              value: selected,
              isExpanded: true,
              items: companies.map((c) {
                return DropdownMenuItem(
                  value: c,
                  child: Text(c.name),
                );
              }).toList(),
              onChanged: (c) {
                if (c != null) onChanged(c);
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
