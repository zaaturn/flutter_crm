import 'package:flutter/material.dart';

/// Survey icons drawn with [CustomPaint] — reliable on web/production builds.
enum SurveyIconType {
  poll,
  list,
  draft,
  active,
  closed,
  add,
  arrowBack,
  delete,
  chevronRight,
}

class SurveyIcon extends StatelessWidget {
  const SurveyIcon({
    super.key,
    required this.type,
    this.size = 20,
    required this.color,
  });

  final SurveyIconType type;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SurveyIconPainter(type: type, color: color),
      ),
    );
  }
}

class _SurveyIconPainter extends CustomPainter {
  _SurveyIconPainter({required this.type, required this.color});

  final SurveyIconType type;
  final Color color;

  Paint get _fill => Paint()
    ..color = color
    ..style = PaintingStyle.fill;

  Paint _stroke([double w = 1.8]) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  @override
  void paint(Canvas canvas, Size s) {
    switch (type) {
      case SurveyIconType.poll:
        _poll(canvas, s);
      case SurveyIconType.list:
        _list(canvas, s);
      case SurveyIconType.draft:
        _draft(canvas, s);
      case SurveyIconType.active:
        _active(canvas, s);
      case SurveyIconType.closed:
        _closed(canvas, s);
      case SurveyIconType.add:
        _add(canvas, s);
      case SurveyIconType.arrowBack:
        _arrowBack(canvas, s);
      case SurveyIconType.delete:
        _delete(canvas, s);
      case SurveyIconType.chevronRight:
        _chevronRight(canvas, s);
    }
  }

  void _poll(Canvas c, Size s) {
    final p = _stroke(s.width * 0.1);
    final barW = s.width * 0.18;
    void bar(double x, double h) {
      c.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, s.height - h, barW, h),
          Radius.circular(barW * 0.2),
        ),
        _fill,
      );
    }
    bar(s.width * 0.12, s.height * 0.35);
    bar(s.width * 0.42, s.height * 0.55);
    bar(s.width * 0.72, s.height * 0.78);
    c.drawLine(
      Offset(s.width * 0.1, s.height * 0.88),
      Offset(s.width * 0.9, s.height * 0.88),
      p,
    );
  }

  void _list(Canvas c, Size s) {
    final p = _stroke(s.width * 0.1);
    for (var i = 0; i < 3; i++) {
      final y = s.height * (0.22 + i * 0.24);
      c.drawLine(Offset(s.width * 0.18, y), Offset(s.width * 0.82, y), p);
      c.drawCircle(Offset(s.width * 0.12, y), s.width * 0.04, _fill);
    }
  }

  void _draft(Canvas c, Size s) {
    final p = _stroke(s.width * 0.09);
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s.width * 0.22, s.height * 0.12, s.width * 0.56, s.height * 0.76),
        const Radius.circular(2),
      ),
      p,
    );
    c.drawLine(Offset(s.width * 0.32, s.height * 0.32), Offset(s.width * 0.68, s.height * 0.32), p);
    c.drawLine(Offset(s.width * 0.32, s.height * 0.48), Offset(s.width * 0.58, s.height * 0.48), p);
    c.drawLine(Offset(s.width * 0.68, s.height * 0.68), Offset(s.width * 0.82, s.height * 0.82), p);
    c.drawLine(Offset(s.width * 0.82, s.height * 0.68), Offset(s.width * 0.68, s.height * 0.82), p);
  }

  void _active(Canvas c, Size s) {
    final p = _stroke(s.width * 0.09);
    final cx = s.width * 0.5;
    final cy = s.height * 0.5;
    final r = s.width * 0.38;
    c.drawCircle(Offset(cx, cy), r, p);
    final path = Path()
      ..moveTo(cx - r * 0.22, cy - r * 0.32)
      ..lineTo(cx + r * 0.38, cy)
      ..lineTo(cx - r * 0.22, cy + r * 0.32)
      ..close();
    c.drawPath(path, _fill);
  }

  void _closed(Canvas c, Size s) {
    final p = _stroke(s.width * 0.09);
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s.width * 0.18, s.height * 0.28, s.width * 0.64, s.height * 0.56),
        const Radius.circular(2),
      ),
      p,
    );
    c.drawLine(Offset(s.width * 0.18, s.height * 0.38), Offset(s.width * 0.82, s.height * 0.38), p);
    c.drawLine(Offset(s.width * 0.32, s.height * 0.12), Offset(s.width * 0.32, s.height * 0.28), p);
    c.drawLine(Offset(s.width * 0.68, s.height * 0.12), Offset(s.width * 0.68, s.height * 0.28), p);
  }

  void _add(Canvas c, Size s) {
    final p = _stroke(s.width * 0.11);
    c.drawLine(Offset(s.width * 0.5, s.height * 0.18), Offset(s.width * 0.5, s.height * 0.82), p);
    c.drawLine(Offset(s.width * 0.18, s.height * 0.5), Offset(s.width * 0.82, s.height * 0.5), p);
  }

  void _arrowBack(Canvas c, Size s) {
    final p = _stroke(s.width * 0.11);
    c.drawLine(Offset(s.width * 0.55, s.height * 0.18), Offset(s.width * 0.22, s.height * 0.5), p);
    c.drawLine(Offset(s.width * 0.22, s.height * 0.5), Offset(s.width * 0.55, s.height * 0.82), p);
    c.drawLine(Offset(s.width * 0.28, s.height * 0.5), Offset(s.width * 0.82, s.height * 0.5), p);
  }

  void _delete(Canvas c, Size s) {
    final p = _stroke(s.width * 0.09);
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s.width * 0.22, s.height * 0.32, s.width * 0.56, s.height * 0.52),
        const Radius.circular(2),
      ),
      p,
    );
    c.drawLine(Offset(s.width * 0.32, s.height * 0.22), Offset(s.width * 0.68, s.height * 0.22), p);
    c.drawLine(Offset(s.width * 0.38, s.height * 0.22), Offset(s.width * 0.38, s.height * 0.32), p);
    c.drawLine(Offset(s.width * 0.62, s.height * 0.22), Offset(s.width * 0.62, s.height * 0.32), p);
    c.drawLine(Offset(s.width * 0.38, s.height * 0.48), Offset(s.width * 0.62, s.height * 0.48), p);
  }

  void _chevronRight(Canvas c, Size s) {
    final p = _stroke(s.width * 0.12);
    c.drawLine(Offset(s.width * 0.38, s.height * 0.18), Offset(s.width * 0.68, s.height * 0.5), p);
    c.drawLine(Offset(s.width * 0.68, s.height * 0.5), Offset(s.width * 0.38, s.height * 0.82), p);
  }

  @override
  bool shouldRepaint(covariant _SurveyIconPainter old) =>
      old.type != type || old.color != color;
}
