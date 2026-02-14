import 'package:flutter/material.dart';

class GroupCard extends StatelessWidget {
  final List<Widget> children;

  const GroupCard({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: children
            .expand((w) => [w, const SizedBox(height: 20)])
            .toList()
          ..removeLast(),
      ),
    );
  }
}
