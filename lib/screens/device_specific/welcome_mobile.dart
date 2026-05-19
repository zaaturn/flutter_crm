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

  // ── Premium mobile palette (cream + terracotta) ───────────────────────────
  static const kBg = Color(0xFFFAF3E0); // cream
  static const kSurface = Color(0xFFF6E7D2); // beige card
  static const kTerracotta = Color(0xFFD9822B);
  static const kTerracottaDark = Color(0xFFB85C1E);
  static const kText = Color(0xFF3E2C1C);
  static const kMuted = Color(0xFF7A5C3E);
  static const kBorder = Color(0x33B85C1E);
  static const kFieldFill = Color(0xFFF2DFC2);

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
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
              child: Form(
                key: _formKey,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),

                      // Brand block (aligned + premium)
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'DAX ARROW',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: kText,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 3,
                              ),
                            ),
                            Text(
                              'VISUALIZE EVERYTHING',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: kTerracottaDark.withOpacity(0.72),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2.6,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Login card in the middle
                      Container(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                        decoration: BoxDecoration(
                          color: kSurface,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: kBorder),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 22,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Welcome Back',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: kText,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.6,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Sign in to continue',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: kMuted.withOpacity(0.9),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 16),

                            if (_error != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xFFFCA5A5),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline_rounded,
                                      color: Color(0xFFB42318),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _error!,
                                        style: const TextStyle(
                                          color: Color(0xFFB42318),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),
                            ],

                            _label('USERNAME'),
                            const SizedBox(height: 8),
                            _field(
                              ctrl: _userCtrl,
                              hint: 'Enter your username',
                              icon: Icons.person_outline_rounded,
                              validator: (v) =>
                                  (v?.isEmpty ?? true) ? 'Required' : null,
                            ),

                            const SizedBox(height: 14),

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
                                    color: kMuted.withOpacity(0.75),
                                  ),
                                ),
                              ),
                              validator: (v) =>
                                  (v?.isEmpty ?? true) ? 'Required' : null,
                            ),

                            const SizedBox(height: 18),

                            SizedBox(
                              height: 54,
                              child: ElevatedButton(
                                onPressed: _loading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kTerracottaDark,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor:
                                      kTerracottaDark.withOpacity(0.45),
                                  disabledForegroundColor:
                                      Colors.white.withOpacity(0.85),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: _loading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor: AlwaysStoppedAnimation(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Sign In',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.6,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(
                                            Icons.arrow_forward_rounded,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0x1AD9822B),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: kBorder),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.lock_rounded,
                                      size: 12,
                                      color: kTerracottaDark,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Secure login',
                                      style: TextStyle(
                                        color: kMuted,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      Center(
                        child: Text(
                          '© 2026 ZAATURN TECHNOLOGIES INC.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: kMuted.withOpacity(0.55),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
        letterSpacing: 2, color: kMuted.withOpacity(0.85),
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
        color: kText,
        fontSize: 14.5,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: kMuted.withOpacity(0.65),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Icon(icon, size: 19, color: kTerracottaDark.withOpacity(0.9)),
        ),
        suffixIcon: suffix,
        filled: true,
        fillColor: kFieldFill,
        border:         _border(),
        enabledBorder:  _border(),
        focusedBorder:  _border(color: kTerracottaDark, width: 1.6),
        errorBorder:    _border(color: Colors.redAccent),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      ),
    );
  }

  OutlineInputBorder _border({Color color = kBorder, double width = 1.2}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(color: color, width: width),
      );

  Widget _footerLink(String t) => Text(
        t,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: kMuted.withOpacity(0.55),
          letterSpacing: 0.3,
        ),
      );
}