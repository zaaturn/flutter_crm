import 'package:flutter/material.dart';

class WelcomeSection extends StatelessWidget {
  final String name;

  const WelcomeSection({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('WELCOME BACK'),
        Text(name, style: const TextStyle(fontSize: 28)),
        const Text('Manage your workspace efficiently.'),
      ],
    );
  }
}