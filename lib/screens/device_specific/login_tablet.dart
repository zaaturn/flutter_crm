import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:my_app/admin_dashboard/shared/admin_dashboard_theme.dart';
import 'package:my_app/services/auth_service.dart';
import 'package:my_app/services/secure_storage_service.dart';
import 'package:my_app/admin_dashboard/screen/admin_dashboard.dart';
import 'package:my_app/employee_dashboard/screen/employee_dashboard_screen.dart';

/// Desktop/tablet login — split-screen SaaS layout on the mint admin shell.
/// Below ~900px the brand panel collapses into a compact header above the
/// form so the same widget still reads well at tablet widths.
class LoginTablet extends StatefulWidget {
  final String role;

  const LoginTablet({super.key, required this.role});

  @override
  State<LoginTablet> createState() => _LoginTabletState();
}

class _LoginTabletState extends State<LoginTablet> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _auth = AuthService();
  final SecureStorageService _storage = SecureStorageService();

  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showMessage('Username and password required');
      return;
    }

    setState(() => _loading = true);

    try {
      final response = await _auth.login(username, password);

      final user = response['user'];
      final role = response['role'];

      if (user == null || role == null) {
        throw Exception('Invalid login response');
      }

      await _storage.saveUser(user);
      await _storage.saveUserId(user['id'].toString());
      await _storage.saveRole(role);

      if (!mounted) return;

      if (role.toString().toLowerCase() == 'admin') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
          (_) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const EmployeeDashboardScreen()),
          (_) => false,
        );
      }
    } catch (_) {
      if (mounted) _showMessage('Login failed');
    }

    if (mounted) setState(() => _loading = false);
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEmployee = widget.role == 'Employee';
    final width = MediaQuery.sizeOf(context).width;
    final isSplit = width >= 900;

    final formPanel = _FormPanel(
      isEmployee: isEmployee,
      usernameController: _usernameController,
      passwordController: _passwordController,
      obscurePassword: _obscurePassword,
      onToggleObscure: () =>
          setState(() => _obscurePassword = !_obscurePassword),
      loading: _loading,
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
              constraints: BoxConstraints(maxWidth: isSplit ? 940 : 460),
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
                                padding: const EdgeInsets.fromLTRB(
                                    48, 56, 48, 48),
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
  final bool isEmployee;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;
  final bool loading;
  final VoidCallback onSubmit;
  final bool compact;

  const _FormPanel({
    required this.isEmployee,
    required this.usernameController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onToggleObscure,
    required this.loading,
    required this.onSubmit,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          compact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isEmployee ? 'Employee Login' : 'Admin Login',
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
        _LoginTextField(
          controller: usernameController,
          label: 'Username',
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 18),
        _LoginTextField(
          controller: passwordController,
          label: 'Password',
          icon: Icons.lock_outline_rounded,
          obscure: obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AdminDashboardTheme.textMuted,
              size: 20,
            ),
            onPressed: onToggleObscure,
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: loading ? null : onSubmit,
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
            child: loading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text(
                    'LOG IN',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _LoginTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final Widget? suffixIcon;

  const _LoginTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
