import 'package:flutter/material.dart';

class AdaptiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget webDesktop;

  const AdaptiveLayout({
    required this.mobile,
    required this.tablet,
    required this.webDesktop,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Desktop / Web large screens
    if (width >= 1000) {
      return webDesktop;
    }

    // Tablet
    if (width >= 700) {
      return tablet;
    }

    // Mobile
    return mobile;
  }
}
