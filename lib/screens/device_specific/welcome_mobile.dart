import 'package:flutter/material.dart';
import 'package:my_app/services/auth_service.dart';
import 'package:my_app/auth/auth_navigation.dart';
import 'package:my_app/services/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class LoginScreenmobile extends StatefulWidget {
  const LoginScreenmobile({super.key});
  @override
  State<LoginScreenmobile> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreenmobile>
    with SingleTickerProviderStateMixin {
  final _formKey  = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _auth     = AuthService();

  bool    _showPass = false;
  bool    _loading  = false;
  String? _error;

  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;

  // ── Brand ─────────────────────────────────────
  static const kBg     = Color(0xFF0A0A0A);
  static const kCard   = Color(0xFF131313);
  static const kGreen  = Color(0xFF4CAF50);
  static const kBorder = Color(0xFF222222);

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      final res  = await _auth.login(_userCtrl.text.trim(), _passCtrl.text.trim());
      try {
        final s = await FirebaseMessaging.instance.requestPermission(
            alert: true, badge: true, sound: true);
        if (s.authorizationStatus == AuthorizationStatus.authorized) {
          final ns = NotificationService();
          await ns.registerDevice(owner: "login");
          ns.listenForTokenRefresh(owner: "login");
        }
      } catch (e) { debugPrint("Push: $e"); }
      if (!mounted) return;
      await AuthNavigation.navigateAfterLogin(context, res);
    } catch (_) {
      setState(() => _error = "Invalid credentials. Please try again.");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ══════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // ── Top green accent bar ─────────────────
                Container(
                  height: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [
                      Colors.transparent, kGreen, Colors.transparent]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 44),

                        // ── Logo + brand name ──────────────
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 52, height: 52,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [BoxShadow(
                                  color: kGreen.withOpacity(0.25),
                                  blurRadius: 20, spreadRadius: 2,
                                )],
                              ),
                              child: Image.asset(
                                'assets/images/logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('DAX ARROW',
                                    style: TextStyle(
                                      color: Colors.white, fontSize: 22,
                                      fontWeight: FontWeight.w900, letterSpacing: 3,
                                    )),
                                Text('VISUALIZE EVERYTHING',
                                    style: TextStyle(
                                      color: kGreen.withOpacity(0.8), fontSize: 9,
                                      fontWeight: FontWeight.w700, letterSpacing: 3,
                                    )),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 52),

                        // ── Welcome Back — single line ─────
                        const Text('Welcome Back',
                          style: TextStyle(
                            color: Colors.white, fontSize: 34,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.0, height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 44, height: 3,
                          decoration: BoxDecoration(
                            color: kGreen,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text('Sign in to continue to your workspace.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.38),
                            fontSize: 13.5, height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 38),

                        // ── Error banner ──────────────────
                        if (_error != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.07),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.red.withOpacity(0.25)),
                            ),
                            child: Row(children: [
                              const Icon(Icons.error_outline_rounded,
                                  color: Colors.redAccent, size: 17),
                              const SizedBox(width: 10),
                              Expanded(child: Text(_error!,
                                  style: const TextStyle(
                                    color: Colors.redAccent, fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ))),
                            ]),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // ── Username ──────────────────────
                        _label('USERNAME'),
                        const SizedBox(height: 8),
                        _field(
                          ctrl: _userCtrl,
                          hint: 'Enter your username',
                          icon: Icons.person_outline_rounded,
                          validator: (v) =>
                          (v?.isEmpty ?? true) ? 'Required' : null,
                        ),

                        const SizedBox(height: 18),

                        // ── Password ──────────────────────
                        _label('PASSWORD'),
                        const SizedBox(height: 8),
                        _field(
                          ctrl: _passCtrl,
                          hint: '••••••••',
                          icon: Icons.lock_outline_rounded,
                          obscure: !_showPass,
                          suffix: GestureDetector(
                            onTap: () =>
                                setState(() => _showPass = !_showPass),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: Icon(
                                _showPass
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 19,
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                          ),
                          validator: (v) =>
                          (v?.isEmpty ?? true) ? 'Required' : null,
                        ),

                        const SizedBox(height: 30),

                        // ── Sign In button ────────────────
                        SizedBox(
                          width: double.infinity, height: 56,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kGreen,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            child: _loading
                                ? const SizedBox(width: 22, height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation(Colors.white),
                                ))
                                : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Sign In',
                                    style: TextStyle(
                                      fontSize: 15, fontWeight: FontWeight.w700,
                                      letterSpacing: 0.8,
                                    )),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, size: 17),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // ── Secure badge ──────────────────
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: kCard,
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(color: kBorder),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.lock_rounded, size: 11,
                                      color: kGreen.withOpacity(0.7)),
                                  const SizedBox(width: 6),
                                  Text('Secure End-to-End Encryption',
                                      style: TextStyle(
                                        fontSize: 10.5, fontWeight: FontWeight.w600,
                                        color: Colors.white.withOpacity(0.3),
                                      )),
                                ]),
                          ),
                        ),

                        const SizedBox(height: 52),

                        // ── Divider ───────────────────────
                        Row(children: [
                          Expanded(child: Divider(color: kBorder)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Text('INTERNAL USE ONLY',
                                style: TextStyle(
                                  fontSize: 9, fontWeight: FontWeight.w700,
                                  letterSpacing: 1.8,
                                  color: Colors.white.withOpacity(0.18),
                                )),
                          ),
                          Expanded(child: Divider(color: kBorder)),
                        ]),

                        const SizedBox(height: 20),

                        // ── Footer links ──────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _footerLink('IT Support'),
                            Container(width: 1, height: 11,
                                margin: const EdgeInsets.symmetric(horizontal: 14),
                                color: kBorder),
                            _footerLink('Security Policy'),
                          ],
                        ),

                        const SizedBox(height: 14),

                        Center(child: Text('© 2026 ZAATURN TECHNOLOGIES INC.',
                            style: TextStyle(
                              fontSize: 9, fontWeight: FontWeight.w600,
                              letterSpacing: 2,
                              color: Colors.white.withOpacity(0.15),
                            ))),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────

  Widget _label(String t) => Text(t,
      style: TextStyle(
        fontSize: 10, fontWeight: FontWeight.w700,
        letterSpacing: 2, color: Colors.white.withOpacity(0.3),
      ));

  Widget _field({
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      enabled: !_loading,
      validator: validator,
      style: const TextStyle(
          color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 14),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Icon(icon, size: 19, color: Colors.white.withOpacity(0.3)),
        ),
        suffixIcon: suffix,
        filled: true,
        fillColor: kCard,
        border:         _border(),
        enabledBorder:  _border(),
        focusedBorder:  _border(color: kGreen, width: 1.5),
        errorBorder:    _border(color: Colors.redAccent),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      ),
    );
  }

  OutlineInputBorder _border({Color color = kBorder, double width = 1.0}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(color: color, width: width),
      );

  Widget _footerLink(String t) => Text(t,
      style: TextStyle(
        fontSize: 11, fontWeight: FontWeight.w600,
        color: Colors.white.withOpacity(0.22), letterSpacing: 0.5,
      ));
}