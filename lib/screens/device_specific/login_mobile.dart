import 'package:flutter/material.dart';

// Services
import 'package:my_app/services/auth_service.dart';
import 'package:my_app/services/secure_storage_service.dart';

// Dashboards
import 'package:my_app/admin_dashboard/screen/admin_dashboard.dart';
import 'package:my_app/employee_dashboard/screen/employee_dashboard_screen.dart';

class LoginMobile extends StatefulWidget {
  final String role;
  final bool showHeaderImages;

  const LoginMobile({
    super.key,
    required this.role,
    this.showHeaderImages = true,
  });

  @override
  State<LoginMobile> createState() => _LoginMobileState();
}

class _LoginMobileState extends State<LoginMobile> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;

  final AuthService auth = AuthService();
  final SecureStorageService storage = SecureStorageService();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEmployee = widget.role == "Employee";

    return Scaffold(
      backgroundColor: const Color(0xFFFAF3E0),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.showHeaderImages) ...[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/images/daxarrow.png',
                                width: 34,
                                height: 34,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(width: 10),
                              Image.asset(
                                'assets/images/logo.png',
                                width: 38,
                                height: 38,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],
                        const Text(
                          'DAX ARROW',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF3E2C1C),
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3,
                          ),
                        ),
                        Text(
                          'VISUALIZE EVERYTHING',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFFB85C1E).withOpacity(0.72),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    isEmployee ? "Employee Login" : "User Login",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF3E2C1C),
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Welcome back",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF7A5C3E).withOpacity(0.9),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLoginCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  Widget _buildLoginCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 30),
      decoration: BoxDecoration(
        color: const Color(0xFFF6E7D2),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x33B85C1E)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTextField(
            controller: usernameController,
            label: "Username",
            icon: Icons.person,
          ),
          const SizedBox(height: 22),
          _buildTextField(
            controller: passwordController,
            label: "Password",
            icon: Icons.lock,
            obscure: true,
          ),
          const SizedBox(height: 30),
          _buildLoginButton(),
        ],
      ),
    );
  }

  // --------------------------------------------------
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFFB85C1E)),
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF2DFC2),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0x33B85C1E), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB85C1E), width: 1.6),
        ),
      ),
    );
  }

  // --------------------------------------------------
  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFB85C1E),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFB85C1E),
          disabledForegroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
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
          "LOGIN",
          style: TextStyle(fontSize: 18, letterSpacing: 1),
        ),
      ),
    );
  }

  // --------------------------------------------------
  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showMessage("Username and password required");
      return;
    }

    setState(() => loading = true);

    try {
      final response = await auth.login(username, password);

      final user = response["user"];
      final role = response["role"];

      if (user == null || role == null) {
        throw Exception("Invalid login response");
      }

      await storage.saveUser(user);
      await storage.saveUserId(user["id"].toString());
      await storage.saveRole(role);

      if (!mounted) return;

      if (role.toString().toLowerCase() == "admin") {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const AdminDashboardScreen(),
          ),
              (_) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const EmployeeDashboardScreen(),
          ),
              (_) => false,
        );
      }
    } catch (_) {
      if (mounted) {
        _showMessage("Login failed");
      }
    }

    if (mounted) setState(() => loading = false);
  }

  // --------------------------------------------------
  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}
