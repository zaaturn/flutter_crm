import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 36), // removed menu

          const Text(
            'Admin Panel',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: Color(0xFF4456BA),
            ),
          ),

          const Icon(Icons.notifications_rounded, color: Color(0xFF4456BA)),
        ],
      ),
    );
  }
}