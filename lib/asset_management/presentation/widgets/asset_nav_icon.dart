import 'package:flutter/material.dart';

import '../../bloc/asset_event.dart';

/// Drawn icons for Assets sidebar / bottom nav — reliable on web production
/// (Material glyph fonts often blank out with the app theme font stack).
class AssetNavIcon extends StatelessWidget {
  const AssetNavIcon({
    super.key,
    required this.tab,
    required this.color,
    this.size = 20,
  });

  final AssetShellTab tab;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _AssetNavPainter(tab: tab, color: color),
      ),
    );
  }
}

class _AssetNavPainter extends CustomPainter {
  _AssetNavPainter({required this.tab, required this.color});

  final AssetShellTab tab;
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
    switch (tab) {
      case AssetShellTab.dashboard:
        _dashboard(canvas, s);
      case AssetShellTab.inventory:
        _inventory(canvas, s);
      case AssetShellTab.myAssets:
        _myAssets(canvas, s);
      case AssetShellTab.scan:
        _scan(canvas, s);
      case AssetShellTab.search:
        _search(canvas, s);
      case AssetShellTab.calendar:
        _calendar(canvas, s);
      case AssetShellTab.pendingRequests:
        _requests(canvas, s);
      case AssetShellTab.pendingReturns:
        _returns(canvas, s);
      case AssetShellTab.pendingDamage:
        _damage(canvas, s);
      case AssetShellTab.guests:
        _guests(canvas, s);
    }
  }

  void _dashboard(Canvas c, Size s) {
    final p = _stroke(s.width * 0.09);
    final gap = s.width * 0.08;
    final cell = (s.width - gap * 3) / 2;
    void cellAt(double x, double y, double h) {
      c.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, cell, h),
          Radius.circular(s.width * 0.06),
        ),
        p,
      );
    }
    cellAt(gap, gap, cell * 0.85);
    cellAt(gap * 2 + cell, gap, cell * 1.25);
    cellAt(gap, gap * 2 + cell * 0.85, cell * 1.25);
    cellAt(gap * 2 + cell, gap * 2 + cell * 1.25, cell * 0.85);
  }

  void _inventory(Canvas c, Size s) {
    final p = _stroke(s.width * 0.09);
    final path = Path()
      ..moveTo(s.width * 0.18, s.height * 0.32)
      ..lineTo(s.width * 0.5, s.height * 0.14)
      ..lineTo(s.width * 0.82, s.height * 0.32)
      ..lineTo(s.width * 0.82, s.height * 0.72)
      ..lineTo(s.width * 0.5, s.height * 0.9)
      ..lineTo(s.width * 0.18, s.height * 0.72)
      ..close();
    c.drawPath(path, p);
    c.drawLine(
      Offset(s.width * 0.18, s.height * 0.32),
      Offset(s.width * 0.5, s.height * 0.5),
      p,
    );
    c.drawLine(
      Offset(s.width * 0.82, s.height * 0.32),
      Offset(s.width * 0.5, s.height * 0.5),
      p,
    );
    c.drawLine(
      Offset(s.width * 0.5, s.height * 0.5),
      Offset(s.width * 0.5, s.height * 0.9),
      p,
    );
  }

  void _myAssets(Canvas c, Size s) {
    final p = _stroke(s.width * 0.09);
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s.width * 0.22, s.height * 0.12, s.width * 0.56, s.height * 0.76),
        Radius.circular(s.width * 0.08),
      ),
      p,
    );
    c.drawLine(
      Offset(s.width * 0.38, s.height * 0.22),
      Offset(s.width * 0.62, s.height * 0.22),
      p,
    );
    c.drawCircle(Offset(s.width * 0.5, s.height * 0.78), s.width * 0.05, _fill);
  }

  void _scan(Canvas c, Size s) {
    final p = _stroke(s.width * 0.1);
    final m = s.width * 0.18;
    final arm = s.width * 0.22;
    // Corner brackets
    void corner(double x, double y, double dx, double dy) {
      c.drawLine(Offset(x, y), Offset(x + dx * arm, y), p);
      c.drawLine(Offset(x, y), Offset(x, y + dy * arm), p);
    }
    corner(m, m, 1, 1);
    corner(s.width - m, m, -1, 1);
    corner(m, s.height - m, 1, -1);
    corner(s.width - m, s.height - m, -1, -1);
    // QR blocks
    c.drawRect(
      Rect.fromLTWH(s.width * 0.32, s.height * 0.32, s.width * 0.16, s.height * 0.16),
      _fill,
    );
    c.drawRect(
      Rect.fromLTWH(s.width * 0.52, s.height * 0.32, s.width * 0.16, s.height * 0.16),
      _fill,
    );
    c.drawRect(
      Rect.fromLTWH(s.width * 0.32, s.height * 0.52, s.width * 0.16, s.height * 0.16),
      _fill,
    );
    c.drawRect(
      Rect.fromLTWH(s.width * 0.55, s.height * 0.55, s.width * 0.1, s.height * 0.1),
      _fill,
    );
  }

  void _search(Canvas c, Size s) {
    final p = _stroke(s.width * 0.1);
    c.drawCircle(Offset(s.width * 0.42, s.height * 0.42), s.width * 0.28, p);
    c.drawLine(
      Offset(s.width * 0.62, s.height * 0.62),
      Offset(s.width * 0.82, s.height * 0.82),
      p,
    );
  }

  void _calendar(Canvas c, Size s) {
    final p = _stroke(s.width * 0.09);
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s.width * 0.14, s.height * 0.22, s.width * 0.72, s.height * 0.64),
        Radius.circular(s.width * 0.06),
      ),
      p,
    );
    c.drawLine(
      Offset(s.width * 0.14, s.height * 0.4),
      Offset(s.width * 0.86, s.height * 0.4),
      p,
    );
    c.drawLine(
      Offset(s.width * 0.32, s.height * 0.12),
      Offset(s.width * 0.32, s.height * 0.28),
      p,
    );
    c.drawLine(
      Offset(s.width * 0.68, s.height * 0.12),
      Offset(s.width * 0.68, s.height * 0.28),
      p,
    );
    c.drawCircle(Offset(s.width * 0.36, s.height * 0.58), s.width * 0.045, _fill);
    c.drawCircle(Offset(s.width * 0.52, s.height * 0.58), s.width * 0.045, _fill);
    c.drawCircle(Offset(s.width * 0.68, s.height * 0.58), s.width * 0.045, _fill);
  }

  void _requests(Canvas c, Size s) {
    final p = _stroke(s.width * 0.09);
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s.width * 0.18, s.height * 0.12, s.width * 0.64, s.height * 0.76),
        Radius.circular(s.width * 0.06),
      ),
      p,
    );
    c.drawLine(
      Offset(s.width * 0.32, s.height * 0.34),
      Offset(s.width * 0.68, s.height * 0.34),
      p,
    );
    c.drawLine(
      Offset(s.width * 0.32, s.height * 0.5),
      Offset(s.width * 0.68, s.height * 0.5),
      p,
    );
    c.drawLine(
      Offset(s.width * 0.32, s.height * 0.66),
      Offset(s.width * 0.55, s.height * 0.66),
      p,
    );
  }

  void _returns(Canvas c, Size s) {
    final p = _stroke(s.width * 0.1);
    // U-turn / return arrow
    final path = Path()
      ..moveTo(s.width * 0.72, s.height * 0.28)
      ..lineTo(s.width * 0.72, s.height * 0.55)
      ..quadraticBezierTo(
        s.width * 0.72,
        s.height * 0.75,
        s.width * 0.5,
        s.height * 0.75,
      )
      ..quadraticBezierTo(
        s.width * 0.28,
        s.height * 0.75,
        s.width * 0.28,
        s.height * 0.55,
      )
      ..lineTo(s.width * 0.28, s.height * 0.38);
    c.drawPath(path, p);
    // Arrow head
    c.drawLine(
      Offset(s.width * 0.28, s.height * 0.38),
      Offset(s.width * 0.18, s.height * 0.48),
      p,
    );
    c.drawLine(
      Offset(s.width * 0.28, s.height * 0.38),
      Offset(s.width * 0.38, s.height * 0.48),
      p,
    );
  }

  void _damage(Canvas c, Size s) {
    final p = _stroke(s.width * 0.09);
    final path = Path()
      ..moveTo(s.width * 0.5, s.height * 0.1)
      ..lineTo(s.width * 0.88, s.height * 0.82)
      ..lineTo(s.width * 0.12, s.height * 0.82)
      ..close();
    c.drawPath(path, p);
    c.drawLine(
      Offset(s.width * 0.5, s.height * 0.38),
      Offset(s.width * 0.5, s.height * 0.58),
      p,
    );
    c.drawCircle(Offset(s.width * 0.5, s.height * 0.7), s.width * 0.04, _fill);
  }

  void _guests(Canvas c, Size s) {
    final p = _stroke(s.width * 0.09);
    c.drawCircle(Offset(s.width * 0.5, s.height * 0.32), s.width * 0.16, p);
    final body = Path()
      ..moveTo(s.width * 0.22, s.height * 0.86)
      ..quadraticBezierTo(
        s.width * 0.22,
        s.height * 0.55,
        s.width * 0.5,
        s.height * 0.55,
      )
      ..quadraticBezierTo(
        s.width * 0.78,
        s.height * 0.55,
        s.width * 0.78,
        s.height * 0.86,
      );
    c.drawPath(body, p);
  }

  @override
  bool shouldRepaint(covariant _AssetNavPainter old) =>
      old.tab != tab || old.color != color;
}
