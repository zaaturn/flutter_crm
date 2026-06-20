import 'package:flutter/material.dart';

/// Bar-chart icon — always visible on web (no Material Icons font).
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
      child: CustomPaint(painter: _SidebarChartIconPainter(color)),
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

/// Upward trend line for Business tab.
class AnalyticsTrendIcon extends StatelessWidget {
  const AnalyticsTrendIcon({
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
      child: CustomPaint(painter: _AnalyticsTrendIconPainter(color)),
    );
  }
}

class _AnalyticsTrendIconPainter extends CustomPainter {
  _AnalyticsTrendIconPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.11;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width * 0.08, size.height * 0.78)
      ..lineTo(size.width * 0.38, size.height * 0.52)
      ..lineTo(size.width * 0.56, size.height * 0.64)
      ..lineTo(size.width * 0.92, size.height * 0.18);
    canvas.drawPath(path, paint);

    final head = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final tip = Offset(size.width * 0.92, size.height * 0.18);
    canvas.drawLine(
      tip,
      Offset(tip.dx - size.width * 0.18, tip.dy),
      paint,
    );
    canvas.drawLine(
      tip,
      Offset(tip.dx, tip.dy + size.height * 0.18),
      paint,
    );
    canvas.drawCircle(tip, stroke * 0.55, head);
  }

  @override
  bool shouldRepaint(covariant _AnalyticsTrendIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

/// Umbrella / leave icon for Leaves tab.
class AnalyticsLeaveIcon extends StatelessWidget {
  const AnalyticsLeaveIcon({
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
      child: CustomPaint(painter: _AnalyticsLeaveIconPainter(color)),
    );
  }
}

class _AnalyticsLeaveIconPainter extends CustomPainter {
  _AnalyticsLeaveIconPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.1;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final cx = size.width * 0.5;
    final top = size.height * 0.22;
    final canopyW = size.width * 0.78;

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(cx, top + canopyW * 0.28),
        width: canopyW,
        height: canopyW * 0.55,
      ),
      3.14159,
      3.14159,
      false,
      paint,
    );

    canvas.drawLine(
      Offset(cx, top + canopyW * 0.28),
      Offset(cx, size.height * 0.88),
      paint,
    );

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(cx, size.height * 0.88),
      stroke * 0.45,
      fill,
    );
  }

  @override
  bool shouldRepaint(covariant _AnalyticsLeaveIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
