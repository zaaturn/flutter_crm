import 'package:flutter/material.dart';
import 'welcome_mobile.dart';

class WelcomeTablet extends StatelessWidget {
  const WelcomeTablet({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/login_bg.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.22)),
          ),
          Center(
            child: SizedBox(
              width: 520, // 🔑 tablet width control
              child: const WelcomeMobile(),
            ),
          ),
        ],
      ),
    );
  }
}
