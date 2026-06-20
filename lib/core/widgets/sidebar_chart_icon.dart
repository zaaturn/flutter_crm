import 'package:flutter/material.dart';

/// Bar-chart icon drawn with [CustomPaint] — always visible on web/production
/// (does not depend on Material Icons font subsetting).
class SidebarChartIcon extends StatelessWidget {
  const SidebarChartIcon({
    super.key,
    this.size = 20,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SidebarChartIconPainter(color),
      ),
    );
  }
}

class _SidebarChartIconPainter extends CustomPainter {
  _SidebarChartIconPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final barW = size.width * 0.24;
    final gap = size.width * 0.1;
    final radius = Radius.circular(barW * 0.2);

    void bar(double index, double heightFactor) {
      final left = index * (barW + gap);
      final barH = size.height * heightFactor;
      final top = size.height - barH;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, barW, barH),
          radius,
        ),
        paint,
      );
    }

    bar(0, 0.45);
    bar(1, 0.85);
    bar(2, 0.62);
  }

  @override
  bool shouldRepaint(covariant _SidebarChartIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
