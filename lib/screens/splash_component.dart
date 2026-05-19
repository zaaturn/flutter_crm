import 'dart:math';
import 'package:flutter/material.dart';

class Particle {
  double x, y, vx, vy, alpha, radius;
  bool isGreen;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.alpha,
    required this.radius,
    required this.isGreen,
  });

  factory Particle.spawn(Random rng, {bool randomY = false}) {
    return Particle(
      x: rng.nextDouble(),
      y: randomY ? rng.nextDouble() : 1.05,
      vx: (rng.nextDouble() - 0.5) * 0.0008,
      vy: -(rng.nextDouble() * 0.001 + 0.0003),
      alpha: rng.nextDouble() * 0.5 + 0.1,
      radius: rng.nextDouble() * 2 + 0.5,
      isGreen: rng.nextDouble() > 0.6,
    );
  }

  void tick() {
    x += vx;
    y += vy;
    alpha -= 0.002;
  }

  bool get isDead => alpha <= 0 || y < -0.02;

  void respawn(Random rng) {
    final p = Particle.spawn(rng);
    x = p.x;
    y = p.y;
    vx = p.vx;
    vy = p.vy;
    alpha = p.alpha;
    radius = p.radius;
    isGreen = p.isGreen;
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = (p.isGreen ? const Color(0xFF4CAF50) : Colors.white)
            .withValues(alpha: p.alpha.clamp(0.0, 1.0)) // Updated from withOpacity to avoid warning
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter old) => true;
}

class CornerBracket extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color color;
  final bool topLeft, topRight, bottomLeft, bottomRight;

  const CornerBracket({
    super.key,
    required this.size,
    required this.strokeWidth,
    required this.color,
    this.topLeft = false,
    this.topRight = false,
    this.bottomLeft = false,
    this.bottomRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: BracketPainter(
        strokeWidth: strokeWidth,
        color: color,
        topLeft: topLeft,
        topRight: topRight,
        bottomLeft: bottomLeft,
        bottomRight: bottomRight,
      ),
    );
  }
}

class BracketPainter extends CustomPainter {
  final double strokeWidth;
  final Color color;
  final bool topLeft, topRight, bottomLeft, bottomRight;

  BracketPainter({
    required this.strokeWidth,
    required this.color,
    this.topLeft = false,
    this.topRight = false,
    this.bottomLeft = false,
    this.bottomRight = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final path = Path();
    final w = size.width;
    final h = size.height;

    if (topLeft) {
      path.moveTo(0, h);
      path.lineTo(0, 0);
      path.lineTo(w, 0);
    } else if (topRight) {
      path.moveTo(0, 0);
      path.lineTo(w, 0);
      path.lineTo(w, h);
    } else if (bottomLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, h);
      path.lineTo(w, h);
    } else if (bottomRight) {
      path.moveTo(0, h);
      path.lineTo(w, h);
      path.lineTo(w, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(BracketPainter old) => false;
}