import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:my_app/screens/device_specific/login_mobile.dart';


class LoginSelector extends StatelessWidget {
  const LoginSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // -------- LOGO --------
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.18),
            border: Border.all(
              color: Colors.yellow.withOpacity(0.45),
              width: 2,
            ),
          ),
          child: const Center(
            child: Text(
              "DA",
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 3,
              ),
            ),
          ),
        ),

        const SizedBox(height: 18),

        // -------- TITLE --------
        const Text(
          "Dax Arrow",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),

        const SizedBox(height: 12),

        // -------- SUBTITLE --------
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 26,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.20),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.yellow.withOpacity(0.35),
              width: 1.4,
            ),
          ),
          child: const Text(
            "Select login type to continue",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.5,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(height: 42),

        // -------- EMPLOYEE BUTTON --------
        _GlassButton(
          label: "Employee Login",
          icon: Icons.person_outline_rounded,
          role: "Employee",
        ),

        const SizedBox(height: 20),

        // -------- ADMIN BUTTON --------
        _GlassButton(
          label: "Admin Login",
          icon: Icons.admin_panel_settings_outlined,
          role: "Admin",
        ),
      ],
    );
  }
}


class WelcomeMobile extends StatelessWidget {
  const WelcomeMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ---------- BACKGROUND ----------
          Positioned.fill(
            child: Image.asset(
              'assets/images/login_bg.jpeg',
              fit: BoxFit.cover,
            ),
          ),

          // ---------- OVERLAY ----------
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.22),
            ),
          ),

          // ---------- CONTENT ----------
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 26),
                child: Transform.translate(
                  offset: const Offset(0, -20),
                  child: const LoginSelector(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _GlassButton extends StatelessWidget {
  const _GlassButton({
    required this.label,
    required this.icon,
    required this.role,
  });

  final String label;
  final IconData icon;
  final String role;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.24),
                  Colors.white.withOpacity(0.12),
                ],
              ),
              border: Border.all(
                color: Colors.yellow.withOpacity(0.65),
                width: 1.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.28),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LoginMobile(role: role),
                    ),
                  );
                },
                splashColor: Colors.white.withOpacity(0.25),
                highlightColor: Colors.white.withOpacity(0.12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
