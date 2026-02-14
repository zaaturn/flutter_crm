import 'package:flutter/material.dart';

class CRMField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final IconData? icon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;

  const CRMField({
    super.key,
    required this.hint,
    required this.controller,
    this.icon,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade100,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black45),
          prefixIcon: icon != null ? Icon(icon, color: Colors.blueGrey) : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

