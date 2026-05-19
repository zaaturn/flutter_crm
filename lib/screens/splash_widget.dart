import 'package:flutter/material.dart';

class DeskIllustration extends StatelessWidget {
  const DeskIllustration({super.key});
  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(72, 72), painter: DeskPainter());
  }
}

class DeskPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final white = Paint()..color = Colors.white.withOpacity(0.85)..strokeWidth = 2.5..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    final greenFill = Paint()..color = const Color(0xFF4CAF50)..style = PaintingStyle.fill;
    final whiteFill = Paint()..color = Colors.white.withOpacity(0.7)..style = PaintingStyle.fill;

    canvas.drawLine(Offset(size.width * 0.5, size.height * 0.9), Offset(size.width * 0.47, size.height * 0.56), white);
    canvas.drawLine(Offset(size.width * 0.47, size.height * 0.56), Offset(size.width * 0.65, size.height * 0.37), white);
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.69, size.height * 0.33), width: 20, height: 10), whiteFill);
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.5, size.height * 0.92), width: 24, height: 6), whiteFill);
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.82, size.height * 0.88), width: 14, height: 6), whiteFill);

    final stemPaint = Paint()..color = const Color(0xFF4CAF50)..strokeWidth = 2..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(size.width * 0.82, size.height * 0.85), Offset(size.width * 0.82, size.height * 0.65), stemPaint);

    final leaf = Path()..moveTo(size.width * 0.82, size.height * 0.65)..relativeQuadraticBezierTo(-10, -6, -12, -14)..relativeQuadraticBezierTo(6, 4, 12, 14);
    canvas.drawPath(leaf, greenFill);
    final leaf2 = Path()..moveTo(size.width * 0.82, size.height * 0.68)..relativeQuadraticBezierTo(10, -6, 12, -14)..relativeQuadraticBezierTo(-6, 4, -12, 14);
    canvas.drawPath(leaf2, greenFill);
  }
  @override
  bool shouldRepaint(CustomPainter old) => false;
}

class ScanLine extends StatefulWidget {
  const ScanLine({super.key});
  @override
  State<ScanLine> createState() => _ScanLineState();
}

class _ScanLineState extends State<ScanLine> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pos;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 5));
    _pos = Tween<double>(begin: -0.01, end: 1.01).animate(CurvedAnimation(parent: _ctrl, curve: Curves.linear));
    Future.delayed(const Duration(seconds: 1), () { if (mounted) _ctrl.repeat(); });
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pos,
      builder: (_, __) => Positioned(
        top: _pos.value * MediaQuery.of(context).size.height,
        left: 0, right: 0,
        child: Container(height: 1, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, const Color(0xFF4CAF50).withOpacity(0.4), Colors.transparent]))),
      ),
    );
  }
}

class PulsingDots extends StatefulWidget {
  const PulsingDots({super.key});
  @override
  State<PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<PulsingDots> with TickerProviderStateMixin {
  late List<AnimationController> _ctrls;
  late List<Animation<double>> _scales;
  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(3, (i) => AnimationController(vsync: this, duration: const Duration(milliseconds: 1400)));
    _scales = _ctrls.map((c) => Tween<double>(begin: 0.6, end: 1.4).animate(CurvedAnimation(parent: c, curve: Curves.easeInOut))).toList();
    for (int i = 0; i < 3; i++) { Future.delayed(Duration(milliseconds: i * 250), () { if (mounted) _ctrls[i].repeat(reverse: true); }); }
  }
  @override
  void dispose() { for (var c in _ctrls) c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: List.generate(3, (i) => AnimatedBuilder(animation: _scales[i], builder: (_, __) => Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child: Transform.scale(scale: _scales[i].value, child: Container(width: 4, height: 4, decoration: const BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle)))))));
  }
}