import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/services/api_services.dart';

class AdminWelcomeScreen extends StatefulWidget {
  const AdminWelcomeScreen({
    super.key,
    this.displayName,
    required this.onDone,
  });

  final String? displayName;
  final VoidCallback onDone;

  @override
  State<AdminWelcomeScreen> createState() => _AdminWelcomeScreenState();
}

class _AdminWelcomeScreenState extends State<AdminWelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ringCtrl;
  String? _resolvedName;

  // Terracotta theme (post-login welcome only; not the app's initial splash)
  static const _bg = Color(0xFFFAF3E0); // warm cream
  static const _accent = Color(0xFFB85C1E); // terracotta
  static const _accentLight = Color(0xFFD58A52); // lighter terracotta
  static const _textDark = Color(0xFF3E2C1C); // deep brown

  @override
  void initState() {
    super.initState();
    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _loadNameIfNeeded();
    // Keep the welcome screen visible a bit longer.
    Future.delayed(const Duration(milliseconds: 5200), () {
      if (mounted) widget.onDone();
    });
  }

  Future<void> _loadNameIfNeeded() async {
    // If AuthNavigation already passed a name, keep it.
    final passed = (widget.displayName ?? '').trim();
    if (passed.isNotEmpty) {
      setState(() => _resolvedName = passed);
      return;
    }
    try {
      final profile = await ProfileService().getProfile();
      final first = (profile['first_name'] ?? profile['firstName'] ?? '')
          .toString()
          .trim();
      final last =
          (profile['last_name'] ?? profile['lastName'] ?? '').toString().trim();
      final full = ('$first $last').trim();
      if (!mounted) return;
      if (full.isNotEmpty) {
        setState(() => _resolvedName = full);
      }
    } catch (e) {
      debugPrint('AdminWelcomeScreen name load failed: $e');
    }
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = (_resolvedName ?? widget.displayName ?? '').trim();
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        alignment: Alignment.center,
        children: [
          _PulsingRings(controller: _ringCtrl, color: _accent),
          const _FloatingDots(),
          // subtle dark gradient for depth
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _textDark.withValues(alpha: 0.06),
                      Colors.transparent,
                      _textDark.withValues(alpha: 0.12),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LogoIcon(accent: _accent),
                const SizedBox(height: 28),
                _Label(text: 'WELCOME BACK', color: _accent, delay: 400),
                const SizedBox(height: 6),
                _BigName(name: name.isEmpty ? 'Admin' : name, delay: 650),
                const SizedBox(height: 10),
                _SubText(
                  text: 'Manage your workspace effectively',
                  color: _accentLight,
                  delay: 900,
                ),
                const SizedBox(height: 24),
                _Divider(color: _accent, delay: 1200),
                const SizedBox(height: 24),
                _GreetText(color: _accent, delay: 1600),
                const SizedBox(height: 40),
                _ContinueBtn(onTap: widget.onDone, accent: _accent, delay: 2000),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoIcon extends StatelessWidget {
  const _LogoIcon({required this.accent});
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFF6E7D2),
        border: Border.all(color: accent, width: 2),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.22),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: ClipOval(
        child: SizedBox(
          width: 64,
          height: 64,
          child: Image.asset(
            'assets/images/logo.png',
            // Cover ensures we don't see a square inside the circle.
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 200.ms)
        .scale(begin: const Offset(0.6, 0.6), curve: Curves.easeOutBack);
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.text, required this.color, required this.delay});
  final String text;
  final Color color;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.manrope(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.14 * 11,
        color: color,
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic);
  }
}

class _BigName extends StatelessWidget {
  const _BigName({required this.name, required this.delay});
  final String name;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      textAlign: TextAlign.center,
      style: GoogleFonts.manrope(
        fontSize: 28,
        fontWeight: FontWeight.w900,
        color: _AdminWelcomeScreenState._textDark,
        height: 1.2,
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 550.ms)
        .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic);
  }
}

class _SubText extends StatelessWidget {
  const _SubText({required this.text, required this.color, required this.delay});
  final String text;
  final Color color;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.55,
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic);
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.color, required this.delay});
  final Color color;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return Container(width: 40, height: 1.5, color: color)
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 400.ms)
        .scaleX(begin: 0, curve: Curves.easeOutCubic);
  }
}

class _GreetText extends StatelessWidget {
  const _GreetText({required this.color, required this.delay});
  final Color color;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Have a great day!',
      style: GoogleFonts.manrope(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: color,
        letterSpacing: 0.4,
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 600.ms)
        .scale(
      begin: const Offset(1.1, 1.1),
      end: const Offset(1, 1),
      curve: Curves.easeOutExpo,
    )
        .shimmer(delay: Duration(milliseconds: delay + 400), duration: 1400.ms);
  }
}

class _ContinueBtn extends StatelessWidget {
  const _ContinueBtn({required this.onTap, required this.accent, required this.delay});
  final VoidCallback onTap;
  final Color accent;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 13),
        decoration: BoxDecoration(
          color: accent,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.22),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Text(
          'Continue',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.2,
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic);
  }
}

class _PulsingRings extends StatelessWidget {
  const _PulsingRings({required this.controller, required this.color});
  final AnimationController controller;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => CustomPaint(
        size: const Size(double.infinity, double.infinity),
        painter: _RingPainter(controller.value, color),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.t, this.color);
  final double t;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    for (final d in [0.0, 0.33, 0.66]) {
      final p = ((t + d) % 1.0);
      final r = 100.0 + p * 160;
      final o = (1 - p) * 0.12;
      canvas.drawCircle(
        Offset(cx, cy),
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = color.withValues(alpha: o),
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.t != t;
}

class _FloatingDots extends StatelessWidget {
  const _FloatingDots();

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(painter: const _DotsPainter()),
    );
  }
}

class _DotsPainter extends CustomPainter {
  const _DotsPainter();

  static final List<Offset> _positions = List.generate(
    20,
        (i) => Offset(
      (i * 73.7 + 30) % 390,
      (i * 111.3 + 60) % 720,
    ),
  );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _AdminWelcomeScreenState._accent.withValues(alpha: 0.12);
    for (final p in _positions) {
      canvas.drawCircle(p, 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}