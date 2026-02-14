import 'package:flutter/material.dart';
import 'package:my_app/core/layout/adaptive_layout.dart';
import 'package:my_app/screens/device_specific/welcome_desktop.dart';
import 'package:my_app/screens/device_specific/welcome_mobile.dart';
import 'package:my_app/screens/device_specific/welcome_tablet.dart';


class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      mobile: const WelcomeMobile(),
      tablet: const WelcomeTablet(),
      webDesktop: const LoginScreen(),
    );
  }
}
