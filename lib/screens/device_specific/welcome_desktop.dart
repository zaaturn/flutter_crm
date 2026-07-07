import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/admin_dashboard/shared/admin_dashboard_theme.dart';
import 'package:my_app/services/auth_service.dart';
import 'package:my_app/auth/auth_navigation.dart';
import 'package:my_app/services/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = AuthService();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _auth.login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );

      final notificationService = NotificationService();

      try {
        NotificationSettings settings =
            await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );

        debugPrint("Permission status: ${settings.authorizationStatus}");

        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          await notificationService.registerDevice(owner: "login");
          // Web: [main.dart] already registers token refresh once; avoid stacking listeners.
          if (!kIsWeb) {
            notificationService.listenForTokenRefresh(owner: "login");
          }
        } else {
          debugPrint("User did not grant notification permission.");
        }
      } catch (e) {
        debugPrint("Push registration error: $e");
      }

      if (!mounted) return;

      await AuthNavigation.navigateAfterLogin(context, response);
    } catch (e) {
      debugPrint("LOGIN ERROR: $e");
      setState(() {
        _errorMessage = "Login failed. Please try again.";
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isSplit = width >= 900;

    final formPanel = _FormPanel(
      formKey: _formKey,
      usernameController: _usernameController,
      passwordController: _passwordController,
      isPasswordVisible: _isPasswordVisible,
      onToggleVisibility: () =>
          setState(() => _isPasswordVisible = !_isPasswordVisible),
      isLoading: _isLoading,
      errorMessage: _errorMessage,
      onSubmit: _handleLogin,
      compact: !isSplit,
    );

    return Scaffold(
      backgroundColor: AdminDashboardTheme.shellMint,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isSplit ? 960 : 460),
              child: Container(
                decoration: BoxDecoration(
                  color: AdminDashboardTheme.surface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AdminDashboardTheme.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: isSplit
                    ? IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Expanded(child: _BrandPanel()),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(48, 56, 48, 48),
                                child: formPanel,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(28, 40, 28, 36),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _CompactBrandHeader(),
                            const SizedBox(height: 32),
                            formPanel,
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
}

/// Left-hand teal brand panel shown at wide (split-screen) widths.
class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AdminDashboardTheme.teal,
            AdminDashboardTheme.tealDark,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -50,
            right: -40,
            child: _softCircle(120, Colors.white.withValues(alpha: 0.08)),
          ),
          Positioned(
            bottom: -60,
            left: -50,
            child: _softCircle(180, Colors.white.withValues(alpha: 0.06)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(48, 56, 40, 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 88,
                    height: 88,
                    color: Colors.white,
                    padding: const EdgeInsets.all(14),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.auto_awesome_rounded,
                        color: AdminDashboardTheme.teal,
                        size: 40,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'DAXARROW',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'VISUALIZE EVERYTHING',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.4,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Digital marketing, branding, social media,\ncontent and campaigns — your creative\nworkspace in one place.',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _softCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// Compact logo + wordmark header shown at tablet widths instead of the
/// full brand panel.
class _CompactBrandHeader extends StatelessWidget {
  const _CompactBrandHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 64,
            height: 64,
            color: AdminDashboardTheme.tealLight,
            padding: const EdgeInsets.all(12),
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.auto_awesome_rounded,
                color: AdminDashboardTheme.teal,
                size: 28,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'DAXARROW',
          style: GoogleFonts.plusJakartaSans(
            color: AdminDashboardTheme.textDark,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),
        Text(
          'VISUALIZE EVERYTHING',
          style: GoogleFonts.plusJakartaSans(
            color: AdminDashboardTheme.teal,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }
}

class _FormPanel extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool isPasswordVisible;
  final VoidCallback onToggleVisibility;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onSubmit;
  final bool compact;

  const _FormPanel({
    required this.formKey,
    required this.usernameController,
    required this.passwordController,
    required this.isPasswordVisible,
    required this.onToggleVisibility,
    required this.isLoading,
    required this.errorMessage,
    required this.onSubmit,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment:
            compact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'User Login',
            textAlign: compact ? TextAlign.center : TextAlign.start,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AdminDashboardTheme.textDark,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Welcome back — enter your details to continue.',
            textAlign: compact ? TextAlign.center : TextAlign.start,
            style: const TextStyle(
              color: AdminDashboardTheme.textMuted,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 28),
          if (errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: Color(0xFFDC2626), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(
                        color: Color(0xFFDC2626),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          _LoginTextField(
            controller: usernameController,
            label: 'Username',
            icon: Icons.person_outline_rounded,
            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            enabled: !isLoading,
          ),
          const SizedBox(height: 18),
          _LoginTextField(
            controller: passwordController,
            label: 'Password',
            icon: Icons.lock_outline_rounded,
            obscure: !isPasswordVisible,
            enabled: !isLoading,
            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            suffixIcon: IconButton(
              icon: Icon(
                isPasswordVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AdminDashboardTheme.textMuted,
                size: 20,
              ),
              onPressed: onToggleVisibility,
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isLoading ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminDashboardTheme.teal,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    AdminDashboardTheme.teal.withValues(alpha: 0.6),
                disabledForegroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Login to Continue',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_rounded,
                  size: 14, color: AdminDashboardTheme.textMuted),
              const SizedBox(width: 6),
              const Text(
                'Secure End-to-End Encryption',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AdminDashboardTheme.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoginTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final bool enabled;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const _LoginTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.enabled = true,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      enabled: enabled,
      validator: validator,
      style: const TextStyle(
        color: AdminDashboardTheme.textDark,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AdminDashboardTheme.teal, size: 20),
        suffixIcon: suffixIcon,
        labelText: label,
        labelStyle: const TextStyle(color: AdminDashboardTheme.textMuted),
        filled: true,
        fillColor: AdminDashboardTheme.surfaceMuted,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AdminDashboardTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AdminDashboardTheme.teal,
            width: 1.6,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDC2626)),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
