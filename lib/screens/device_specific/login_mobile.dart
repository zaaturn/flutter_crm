import 'package:flutter/material.dart';

// Services
import 'package:my_app/services/auth_service.dart';
import 'package:my_app/services/secure_storage_service.dart';

// Dashboards
import 'package:my_app/admin_dashboard/screen/admin_dashboard.dart';
import 'package:my_app/employee_dashboard/screen/employee_dashboard_screen.dart';

class LoginMobile extends StatefulWidget {
  final String role;

  const LoginMobile({super.key, required this.role});

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
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
          child: Column(
            children: [
              const Icon(
                Icons.lock_outline,
                size: 80,
                color: Colors.blueAccent,
              ),
              const SizedBox(height: 20),

              Text(
                isEmployee ? "Employee Login" : "Admin Login",
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),
              const Text(
                "Welcome back 👋",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 40),
              _buildLoginCard(),
            ],
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            spreadRadius: 2,
            offset: Offset(0, 4),
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
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blueAccent),
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
          backgroundColor: Colors.blueAccent,
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
