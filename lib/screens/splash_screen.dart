import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'splash_component.dart';
import 'splash_widget.dart';
import 'package:my_app/core/router/startup_gate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  bool _leftSplash = false;

  void _goToStartupGate() {
    if (_leftSplash || !mounted) return;
    _leftSplash = true;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const StartupGate()),
    );
  }

  // Brand Colors
  static const Color kGreen = Color(0xFF4CAF50);
  static const Color kGreenLight = Color(0xFF81C784);
  static const Color kGreenDark = Color(0xFF2E7D32);
  static const Color kBlack = Color(0xFF0C0C0C);

  // Controllers
  late AnimationController _headlineCtrl,
      _ovalCtrl,
      _lineCtrl,
      _pillCtrl,
      _logoSpinCtrl,
      _deskCtrl,
      _tagCtrl,
      _loaderCtrl,
      _glowCtrl,
      _greenPulseCtrl,
      _particleCtrl;

  // Animations
  late Animation<Offset> _headlineOffset, _deskOffset, _tagOffset;
  late Animation<double> _headlineFade,
      _ovalScale,
      _ovalFade,
      _lineProgress,
      _pillScale,
      _pillFade,
      _logoAngle,
      _deskFade,
      _tagFade,
      _loaderProgress,
      _glowOpacity,
      _greenBlur;

  final List<Particle> _particles = [];
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 80; i++) {
      _particles.add(Particle.spawn(_rng, randomY: true));
    }
    _setupAnimations();
    // Failsafe if animation tickers stall (e.g. some device states) — never block startup forever.
    Future.delayed(const Duration(seconds: 8), _goToStartupGate);
    _runSequence();
  }

  void _setupAnimations() {
    // 1. Headline
    _headlineCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _headlineOffset = Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headlineCtrl, curve: Curves.easeOut));
    _headlineFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _headlineCtrl, curve: Curves.easeOut));

    // 2. Oval
    _ovalCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _ovalScale = Tween<double>(begin: 0.75, end: 1.0).animate(CurvedAnimation(parent: _ovalCtrl, curve: Curves.easeOutBack));
    _ovalFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ovalCtrl, curve: Curves.easeOut));

    // 3. Line
    _lineCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _lineProgress = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _lineCtrl, curve: Curves.easeOut));

    // 4. Pill
    _pillCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _pillScale = Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _pillCtrl, curve: Curves.elasticOut));
    _pillFade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _pillCtrl, curve: const Interval(0.0, 0.4, curve: Curves.easeIn)));

    // 5. Logo
    _logoSpinCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _logoAngle = Tween<double>(begin: -pi, end: 0).animate(CurvedAnimation(parent: _logoSpinCtrl, curve: Curves.elasticOut));

    // 6. Desk
    _deskCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _deskFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _deskCtrl, curve: Curves.easeOut));
    _deskOffset = Tween<Offset>(begin: const Offset(0, 0.6), end: Offset.zero)
        .animate(CurvedAnimation(parent: _deskCtrl, curve: Curves.easeOut));

    // 7. Tag
    _tagCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _tagFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _tagCtrl, curve: Curves.easeOut));
    _tagOffset = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(CurvedAnimation(parent: _tagCtrl, curve: Curves.easeOut));

    // 8. Loader
    _loaderCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 4000));
    _loaderProgress = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.72), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 0.72, end: 0.90), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.90, end: 1.0), weight: 15),
    ]).animate(CurvedAnimation(parent: _loaderCtrl, curve: Curves.linear));

    // 9. Glows
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000))..repeat(reverse: true);
    _glowOpacity = Tween<double>(begin: 0.04, end: 0.12).animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    _greenPulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat(reverse: true);
    _greenBlur =
        Tween<double>(begin: 4, end: 18).animate(CurvedAnimation(parent: _greenPulseCtrl, curve: Curves.easeInOut));

    _particleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 16))
      ..addListener(() {
        setState(() {
          for (var p in _particles) {
            p.tick();
            if (p.isDead) p.respawn(_rng);
          }
        });
      })
      ..repeat();
  }

  void _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _headlineCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 700));
    _ovalCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _lineCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _pillCtrl.forward();
    _logoSpinCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    _deskCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _tagCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    try {
      await _loaderCtrl.forward();
    } finally {
      _goToStartupGate();
    }
  }

  @override
  void dispose() {
    _headlineCtrl.dispose();
    _ovalCtrl.dispose();
    _lineCtrl.dispose();
    _pillCtrl.dispose();
    _logoSpinCtrl.dispose();
    _deskCtrl.dispose();
    _tagCtrl.dispose();
    _loaderCtrl.dispose();
    _glowCtrl.dispose();
    _greenPulseCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: kBlack,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _glowOpacity,
            builder: (_, __) => Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, 0.3),
                  radius: 0.8,
                  colors: [
                    kGreen.withOpacity(_glowOpacity.value),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          CustomPaint(size: size, painter: ParticlePainter(_particles)),
          ..._buildCornerBrackets(),
          const ScanLine(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // PUSH TO MIDDLE
                  const Spacer(flex: 2),

                  _buildHeadline(),
                  const SizedBox(height: 60),
                  Center(child: _buildLogoPill()),
                  const SizedBox(height: 40),
                  Center(child: _buildTagline()),

                  // PUSH LOADER TO BOTTOM
                  const Spacer(flex: 3),

                  Center(child: _buildLoader()),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeadline() {
    return AnimatedBuilder(
      animation: Listenable.merge([_headlineCtrl, _ovalCtrl, _lineCtrl]),
      builder: (_, __) => FadeTransition(
        opacity: _headlineFade,
        child: SlideTransition(
          position: _headlineOffset,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Better\nfor your',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w300,
                      height: 1.2,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Transform.scale(
                    scale: _ovalScale.value,
                    child: Opacity(
                      opacity: _ovalFade.value,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TEAM',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 3,
                                height: 1.1,
                              ),
                            ),
                            Text(
                              'VISION',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 3,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (ctx, constraints) => Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 1,
                    width: constraints.maxWidth * _lineProgress.value,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoPill() {
    return AnimatedBuilder(
      animation: Listenable.merge([_pillCtrl, _logoSpinCtrl, _deskCtrl]),
      builder: (_, __) => Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -52,
            right: 16,
            child: FadeTransition(
              opacity: _deskFade,
              child: SlideTransition(
                position: _deskOffset,
                child: const DeskIllustration(),
              ),
            ),
          ),
          Opacity(
            opacity: _pillFade.value.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: _pillScale.value.clamp(0.0, 1.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: kGreen.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.rotate(
                      angle: _logoAngle.value,
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 52,
                        height: 52,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'DAX ARROW',
                          style: TextStyle(
                            color: Color(0xFF111111),
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'VISUALIZE EVERYTHING',
                          style: TextStyle(
                            color: Color(0xFF444444),
                            fontSize: 7.5,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 2.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagline() {
    return AnimatedBuilder(
      animation: Listenable.merge([_tagCtrl, _greenPulseCtrl]),
      builder: (_, __) => FadeTransition(
        opacity: _tagFade,
        child: SlideTransition(
          position: _tagOffset,
          child: Column(
            children: [
              Text(
                'DIGITAL MARKETING  |  BRANDING',
                style: TextStyle(
                  color: kGreen,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 4,
                  shadows: [
                    Shadow(
                      color: kGreen.withOpacity(0.8),
                      blurRadius: _greenBlur.value,
                    ),
                    Shadow(
                      color: kGreen.withOpacity(0.4),
                      blurRadius: _greenBlur.value * 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Visualize Everything',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 11,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoader() {
    return AnimatedBuilder(
      animation: _loaderCtrl,
      builder: (_, __) => Column(
        children: [
          Container(
            width: 180,
            height: 2,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: _loaderProgress.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kGreenDark, kGreen, kGreenLight],
                    ),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: kGreen.withOpacity(0.6),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const PulsingDots(),
        ],
      ),
    );
  }

  List<Widget> _buildCornerBrackets() {
    const color = Color(0x4D4CAF50);
    const size = 55.0;
    const thick = 1.0;
    return [
      Positioned(
        top: 18,
        left: 18,
        child: CornerBracket(size: size, strokeWidth: thick, color: color, topLeft: true),
      ),
      Positioned(
        top: 18,
        right: 18,
        child: CornerBracket(size: size, strokeWidth: thick, color: color, topRight: true),
      ),
      Positioned(
        bottom: 18,
        left: 18,
        child: CornerBracket(size: size, strokeWidth: thick, color: color, bottomLeft: true),
      ),
      Positioned(
        bottom: 18,
        right: 18,
        child: CornerBracket(size: size, strokeWidth: thick, color: color, bottomRight: true),
      ),
    ];
  }
}