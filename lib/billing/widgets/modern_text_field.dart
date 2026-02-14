import 'package:flutter/material.dart';

class ModernTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool required;
  final int maxLines;
  final TextInputType? keyboardType;

  const ModernTextField({
    super.key,
    required this.label,
    required this.controller,
    this.required = false,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label + (required ? " *" : ""),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator:
          required ? (v) => v!.isEmpty ? "Required" : null : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
              BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF0061FF),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
