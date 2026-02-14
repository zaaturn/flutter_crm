import 'package:flutter/material.dart';

class CurrencyDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const CurrencyDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Default Currency",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
              BorderSide(color: Colors.grey.shade200),
            ),
          ),
          items: const [
            DropdownMenuItem(
              value: "INR",
              child: Text("INR (₹)"),
            ),
            DropdownMenuItem(
              value: "USD",
              child: Text("USD (\$)"),
            ),
          ],
          onChanged: (v) => onChanged(v!),
        ),
      ],
    );
  }
}
