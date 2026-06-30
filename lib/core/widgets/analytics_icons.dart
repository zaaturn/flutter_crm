import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Analytics icons drawn with [CustomPaint] — reliable on web/production builds.
enum AnalyticsIconType {
  barChart,
  overview,
  calendar,
  business,
  leaves,
  receipt,
  people,
  login,
  onLeave,
  pendingLeave,
  tasks,
  payments,
  wallet,
  personAdd,
  building,
  document,
  checkCircle,
  pending,
  hourglass,
  chevronLeft,
  chevronRight,
  arrowBack,
  refresh,
  check,
  lock,
  cloudOff,
  settings,
  support,
}

class AnalyticsIcon extends StatelessWidget {
  const AnalyticsIcon({
    super.key,
    required this.type,
    this.size = 20,
    required this.color,
  });

  final AnalyticsIconType type;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _AnalyticsIconPainter(type: type, color: color),
      ),
    );
  }
}

class _AnalyticsIconPainter extends CustomPainter {
  _AnalyticsIconPainter({required this.type, required this.color});

  final AnalyticsIconType type;
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
      case AnalyticsIconType.barChart:
        _barChart(canvas, s);
      case AnalyticsIconType.overview:
        _grid(canvas, s);
      case AnalyticsIconType.calendar:
        _calendar(canvas, s);
      case AnalyticsIconType.business:
        _trend(canvas, s);
      case AnalyticsIconType.leaves:
      case AnalyticsIconType.onLeave:
        _umbrella(canvas, s);
      case AnalyticsIconType.receipt:
        _receipt(canvas, s);
      case AnalyticsIconType.people:
        _people(canvas, s);
      case AnalyticsIconType.login:
        _login(canvas, s);
      case AnalyticsIconType.pendingLeave:
        _clock(canvas, s);
      case AnalyticsIconType.tasks:
        _check(canvas, s);
      case AnalyticsIconType.payments:
        _payments(canvas, s);
      case AnalyticsIconType.wallet:
        _wallet(canvas, s);
      case AnalyticsIconType.personAdd:
        _personAdd(canvas, s);
      case AnalyticsIconType.building:
        _building(canvas, s);
      case AnalyticsIconType.document:
        _document(canvas, s);
      case AnalyticsIconType.checkCircle:
        _checkCircle(canvas, s);
      case AnalyticsIconType.pending:
        _pending(canvas, s);
      case AnalyticsIconType.hourglass:
        _hourglass(canvas, s);
      case AnalyticsIconType.chevronLeft:
        _chevron(canvas, s, left: true);
      case AnalyticsIconType.chevronRight:
        _chevron(canvas, s, left: false);
      case AnalyticsIconType.arrowBack:
        _arrowBack(canvas, s);
      case AnalyticsIconType.refresh:
        _refresh(canvas, s);
      case AnalyticsIconType.check:
        _check(canvas, s);
      case AnalyticsIconType.lock:
        _lock(canvas, s);
      case AnalyticsIconType.cloudOff:
        _cloudOff(canvas, s);
      case AnalyticsIconType.settings:
        _settings(canvas, s);
      case AnalyticsIconType.support:
        _support(canvas, s);
    }
  }

  void _barChart(Canvas c, Size s) {
    final w = s.width * 0.28;
    final gap = s.width * 0.08;
    final r = Radius.circular(w * 0.22);
    void bar(int i, double h) {
      final left = i * (w + gap);
      final barH = (s.height * h).clamp(s.height * 0.2, s.height);
      c.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, s.height - barH, w, barH),
          r,
        ),
        _fill,
      );
    }
    bar(0, 0.5);
    bar(1, 0.92);
    bar(2, 0.68);
  }

  void _grid(Canvas c, Size s) {
    final cell = s.width * 0.38;
    final gap = s.width * 0.08;
    final r = Radius.circular(2);
    for (var row = 0; row < 2; row++) {
      for (var col = 0; col < 2; col++) {
        c.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(col * (cell + gap), row * (cell + gap), cell, cell),
            r,
          ),
          _fill,
        );
      }
    }
  }

  void _calendar(Canvas c, Size s) {
    final p = _stroke(s.width * 0.09);
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(s.width * 0.1, s.height * 0.22, s.width * 0.8, s.height * 0.68),
      const Radius.circular(2),
    );
    c.drawRRect(r, p);
    c.drawLine(Offset(s.width * 0.1, s.height * 0.38), Offset(s.width * 0.9, s.height * 0.38), p);
    c.drawLine(Offset(s.width * 0.28, s.height * 0.12), Offset(s.width * 0.28, s.height * 0.3), p);
    c.drawLine(Offset(s.width * 0.72, s.height * 0.12), Offset(s.width * 0.72, s.height * 0.3), p);
    for (var i = 0; i < 3; i++) {
      c.drawCircle(Offset(s.width * (0.28 + i * 0.22), s.height * 0.58), s.width * 0.05, _fill);
    }
  }

  void _trend(Canvas c, Size s) {
    final p = _stroke(s.width * 0.11);
    final path = Path()
      ..moveTo(s.width * 0.08, s.height * 0.78)
      ..lineTo(s.width * 0.38, s.height * 0.52)
      ..lineTo(s.width * 0.56, s.height * 0.64)
      ..lineTo(s.width * 0.92, s.height * 0.18);
    c.drawPath(path, p);
    final tip = Offset(s.width * 0.92, s.height * 0.18);
    c.drawLine(tip, Offset(tip.dx - s.width * 0.16, tip.dy), p);
    c.drawLine(tip, Offset(tip.dx, tip.dy + s.height * 0.16), p);
  }

  void _umbrella(Canvas c, Size s) {
    final p = _stroke(s.width * 0.1);
    final cx = s.width * 0.5;
    c.drawArc(
      Rect.fromCenter(center: Offset(cx, s.height * 0.42), width: s.width * 0.78, height: s.height * 0.42),
      3.14159, 3.14159, false, p,
    );
    c.drawLine(Offset(cx, s.height * 0.42), Offset(cx, s.height * 0.88), p);
    c.drawCircle(Offset(cx, s.height * 0.88), s.width * 0.05, _fill);
  }

  void _receipt(Canvas c, Size s) {
    final p = _stroke(s.width * 0.09);
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(s.width * 0.18, s.height * 0.1, s.width * 0.64, s.height * 0.8),
      const Radius.circular(2),
    );
    c.drawRRect(body, p);
    for (var i = 0; i < 3; i++) {
      final y = s.height * (0.32 + i * 0.18);
      c.drawLine(Offset(s.width * 0.28, y), Offset(s.width * 0.72, y), p);
    }
  }

  void _people(Canvas c, Size s) {
    void person(double cx, double scale) {
      c.drawCircle(Offset(cx, s.height * 0.28 * scale + s.height * 0.08), s.width * 0.11 * scale, _fill);
      c.drawArc(
        Rect.fromCenter(center: Offset(cx, s.height * 0.72), width: s.width * 0.28 * scale, height: s.height * 0.32),
        3.14159, 3.14159, false, _fill,
      );
    }
    person(s.width * 0.36, 1);
    person(s.width * 0.68, 0.85);
  }

  void _login(Canvas c, Size s) {
    final p = _stroke(s.width * 0.1);
    c.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(s.width * 0.08, s.height * 0.18, s.width * 0.42, s.height * 0.64), const Radius.circular(2)),
      p,
    );
    c.drawLine(Offset(s.width * 0.5, s.height * 0.5), Offset(s.width * 0.88, s.height * 0.5), p);
    c.drawLine(Offset(s.width * 0.72, s.height * 0.36), Offset(s.width * 0.88, s.height * 0.5), p);
    c.drawLine(Offset(s.width * 0.72, s.height * 0.64), Offset(s.width * 0.88, s.height * 0.5), p);
  }

  void _clock(Canvas c, Size s) {
    final p = _stroke(s.width * 0.1);
    c.drawCircle(Offset(s.width * 0.5, s.height * 0.5), s.width * 0.38, p);
    c.drawLine(Offset(s.width * 0.5, s.height * 0.5), Offset(s.width * 0.5, s.height * 0.28), p);
    c.drawLine(Offset(s.width * 0.5, s.height * 0.5), Offset(s.width * 0.68, s.height * 0.5), p);
  }

  void _check(Canvas c, Size s) {
    final p = _stroke(s.width * 0.12);
    c.drawLine(Offset(s.width * 0.18, s.height * 0.52), Offset(s.width * 0.42, s.height * 0.76), p);
    c.drawLine(Offset(s.width * 0.42, s.height * 0.76), Offset(s.width * 0.82, s.height * 0.24), p);
  }

  void _payments(Canvas c, Size s) {
    final p = _stroke(s.width * 0.09);
    c.drawCircle(Offset(s.width * 0.38, s.height * 0.5), s.width * 0.28, p);
    c.drawLine(Offset(s.width * 0.62, s.height * 0.32), Offset(s.width * 0.88, s.height * 0.58), p);
    c.drawLine(Offset(s.width * 0.62, s.height * 0.58), Offset(s.width * 0.88, s.height * 0.32), p);
  }

  void _wallet(Canvas c, Size s) {
    final p = _stroke(s.width * 0.09);
    c.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(s.width * 0.1, s.height * 0.28, s.width * 0.8, s.height * 0.52), const Radius.circular(3)),
      p,
    );
    c.drawCircle(Offset(s.width * 0.72, s.height * 0.54), s.width * 0.08, _fill);
    c.drawLine(Offset(s.width * 0.1, s.height * 0.28), Offset(s.width * 0.38, s.height * 0.12), p);
    c.drawLine(Offset(s.width * 0.38, s.height * 0.12), Offset(s.width * 0.9, s.height * 0.12), p);
    c.drawLine(Offset(s.width * 0.9, s.height * 0.12), Offset(s.width * 0.9, s.height * 0.28), p);
  }

  void _personAdd(Canvas c, Size s) {
    c.drawCircle(Offset(s.width * 0.38, s.height * 0.3), s.width * 0.14, _fill);
    c.drawArc(
      Rect.fromCenter(center: Offset(s.width * 0.38, s.height * 0.78), width: s.width * 0.34, height: s.height * 0.34),
      3.14159, 3.14159, false, _fill,
    );
    final p = _stroke(s.width * 0.1);
    c.drawLine(Offset(s.width * 0.72, s.height * 0.42), Offset(s.width * 0.72, s.height * 0.68), p);
    c.drawLine(Offset(s.width * 0.6, s.height * 0.55), Offset(s.width * 0.84, s.height * 0.55), p);
  }

  void _building(Canvas c, Size s) {
    final p = _stroke(s.width * 0.09);
    c.drawRect(Rect.fromLTWH(s.width * 0.22, s.height * 0.14, s.width * 0.56, s.height * 0.78), p);
    for (var row = 0; row < 3; row++) {
      for (var col = 0; col < 2; col++) {
        c.drawRect(
          Rect.fromLTWH(s.width * (0.32 + col * 0.2), s.height * (0.26 + row * 0.2), s.width * 0.1, s.height * 0.1),
          _fill,
        );
      }
    }
  }

  void _document(Canvas c, Size s) {
    final p = _stroke(s.width * 0.09);
    final path = Path()
      ..moveTo(s.width * 0.2, s.height * 0.12)
      ..lineTo(s.width * 0.58, s.height * 0.12)
      ..lineTo(s.width * 0.8, s.height * 0.34)
      ..lineTo(s.width * 0.8, s.height * 0.88)
      ..lineTo(s.width * 0.2, s.height * 0.88)
      ..close();
    c.drawPath(path, p);
    c.drawLine(Offset(s.width * 0.58, s.height * 0.12), Offset(s.width * 0.58, s.height * 0.34), p);
    c.drawLine(Offset(s.width * 0.58, s.height * 0.34), Offset(s.width * 0.8, s.height * 0.34), p);
  }

  void _checkCircle(Canvas c, Size s) {
    final p = _stroke(s.width * 0.1);
    c.drawCircle(Offset(s.width * 0.5, s.height * 0.5), s.width * 0.38, p);
    c.drawLine(Offset(s.width * 0.32, s.height * 0.52), Offset(s.width * 0.46, s.height * 0.66), p);
    c.drawLine(Offset(s.width * 0.46, s.height * 0.66), Offset(s.width * 0.72, s.height * 0.34), p);
  }

  void _pending(Canvas c, Size s) {
    final p = _stroke(s.width * 0.1);
    c.drawCircle(Offset(s.width * 0.5, s.height * 0.5), s.width * 0.38, p);
    c.drawLine(Offset(s.width * 0.35, s.height * 0.5), Offset(s.width * 0.65, s.height * 0.5), p);
  }

  void _hourglass(Canvas c, Size s) {
    final p = _stroke(s.width * 0.1);
    c.drawLine(Offset(s.width * 0.22, s.height * 0.14), Offset(s.width * 0.78, s.height * 0.14), p);
    c.drawLine(Offset(s.width * 0.22, s.height * 0.86), Offset(s.width * 0.78, s.height * 0.86), p);
    c.drawLine(Offset(s.width * 0.22, s.height * 0.14), Offset(s.width * 0.5, s.height * 0.5), p);
    c.drawLine(Offset(s.width * 0.78, s.height * 0.14), Offset(s.width * 0.5, s.height * 0.5), p);
    c.drawLine(Offset(s.width * 0.22, s.height * 0.86), Offset(s.width * 0.5, s.height * 0.5), p);
    c.drawLine(Offset(s.width * 0.78, s.height * 0.86), Offset(s.width * 0.5, s.height * 0.5), p);
  }

  void _chevron(Canvas c, Size s, {required bool left}) {
    final p = _stroke(s.width * 0.12);
    if (left) {
      c.drawLine(Offset(s.width * 0.62, s.height * 0.18), Offset(s.width * 0.32, s.height * 0.5), p);
      c.drawLine(Offset(s.width * 0.32, s.height * 0.5), Offset(s.width * 0.62, s.height * 0.82), p);
    } else {
      c.drawLine(Offset(s.width * 0.38, s.height * 0.18), Offset(s.width * 0.68, s.height * 0.5), p);
      c.drawLine(Offset(s.width * 0.68, s.height * 0.5), Offset(s.width * 0.38, s.height * 0.82), p);
    }
  }

  void _arrowBack(Canvas c, Size s) {
    final p = _stroke(s.width * 0.11);
    c.drawLine(Offset(s.width * 0.55, s.height * 0.18), Offset(s.width * 0.22, s.height * 0.5), p);
    c.drawLine(Offset(s.width * 0.22, s.height * 0.5), Offset(s.width * 0.55, s.height * 0.82), p);
    c.drawLine(Offset(s.width * 0.28, s.height * 0.5), Offset(s.width * 0.82, s.height * 0.5), p);
  }

  void _refresh(Canvas c, Size s) {
    final p = _stroke(s.width * 0.1);
    c.drawArc(
      Rect.fromLTWH(s.width * 0.14, s.height * 0.14, s.width * 0.72, s.height * 0.72),
      -0.5, 4.5, false, p,
    );
    c.drawLine(Offset(s.width * 0.72, s.height * 0.22), Offset(s.width * 0.86, s.height * 0.12), p);
    c.drawLine(Offset(s.width * 0.72, s.height * 0.22), Offset(s.width * 0.78, s.height * 0.38), p);
  }

  void _lock(Canvas c, Size s) {
    final p = _stroke(s.width * 0.1);
    c.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(s.width * 0.24, s.height * 0.44, s.width * 0.52, s.height * 0.42), const Radius.circular(3)),
      p,
    );
    c.drawArc(
      Rect.fromCenter(center: Offset(s.width * 0.5, s.height * 0.4), width: s.width * 0.36, height: s.height * 0.36),
      3.14159, 3.14159, false, p,
    );
  }

  void _cloudOff(Canvas c, Size s) {
    final p = _stroke(s.width * 0.09);
    c.drawArc(Rect.fromLTWH(s.width * 0.08, s.height * 0.38, s.width * 0.42, s.height * 0.38), 3.14159, 3.14159, false, p);
    c.drawArc(Rect.fromLTWH(s.width * 0.32, s.height * 0.28, s.width * 0.5, s.height * 0.42), 3.14159, 3.14159, false, p);
    c.drawLine(Offset(s.width * 0.18, s.height * 0.78), Offset(s.width * 0.82, s.height * 0.22), p);
  }

  void _settings(Canvas c, Size s) {
    final p = _stroke(s.width * 0.1);
    c.drawCircle(Offset(s.width * 0.5, s.height * 0.5), s.width * 0.18, p);
    for (var i = 0; i < 8; i++) {
      final angle = i * 3.14159 / 4;
      final inner = s.width * 0.24;
      final outer = s.width * 0.38;
      c.drawLine(
        Offset(s.width * 0.5 + inner * _cos(angle), s.height * 0.5 + inner * _sin(angle)),
        Offset(s.width * 0.5 + outer * _cos(angle), s.height * 0.5 + outer * _sin(angle)),
        p,
      );
    }
  }

  double _cos(double a) => math.cos(a);
  double _sin(double a) => math.sin(a);

  void _support(Canvas c, Size s) {
    final p = _stroke(s.width * 0.1);
    final padW = s.width * 0.2;
    final padH = s.height * 0.3;
    final padY = s.height * 0.4;

    c.drawArc(
      Rect.fromLTWH(s.width * 0.14, s.height * 0.1, s.width * 0.72, s.height * 0.5),
      3.14159,
      3.14159,
      false,
      p,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s.width * 0.08, padY, padW, padH),
        const Radius.circular(3),
      ),
      p,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s.width * 0.72, padY, padW, padH),
        const Radius.circular(3),
      ),
      p,
    );
    c.drawLine(
      Offset(s.width * 0.52, s.height * 0.66),
      Offset(s.width * 0.7, s.height * 0.84),
      p,
    );
    c.drawCircle(Offset(s.width * 0.74, s.height * 0.86), s.width * 0.055, _fill);
  }

  @override
  bool shouldRepaint(covariant _AnalyticsIconPainter old) =>
      old.type != type || old.color != color;
}

// Backward-compatible aliases used by admin sidebar.
class SidebarChartIcon extends StatelessWidget {
  const SidebarChartIcon({super.key, this.size = 20, required this.color});
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) =>
      AnalyticsIcon(type: AnalyticsIconType.barChart, size: size, color: color);
}

class SidebarSettingsIcon extends StatelessWidget {
  const SidebarSettingsIcon({super.key, this.size = 20, required this.color});
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) =>
      AnalyticsIcon(type: AnalyticsIconType.settings, size: size, color: color);
}

class SidebarSupportIcon extends StatelessWidget {
  const SidebarSupportIcon({super.key, this.size = 20, required this.color});
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) =>
      AnalyticsIcon(type: AnalyticsIconType.support, size: size, color: color);
}

class AnalyticsTrendIcon extends StatelessWidget {
  const AnalyticsTrendIcon({super.key, this.size = 20, required this.color});
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) =>
      AnalyticsIcon(type: AnalyticsIconType.business, size: size, color: color);
}

class AnalyticsLeaveIcon extends StatelessWidget {
  const AnalyticsLeaveIcon({super.key, this.size = 20, required this.color});
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) =>
      AnalyticsIcon(type: AnalyticsIconType.leaves, size: size, color: color);
}
