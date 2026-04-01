import 'package:flutter/material.dart';

class ColorDot extends StatelessWidget {
  final Color color;
  final double size;
  final bool selected;

  const ColorDot({
    super.key,
    required this.color,
    this.size = 28,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? Colors.black87 : Colors.transparent,
          width: selected ? 2 : 0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}
