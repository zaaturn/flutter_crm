import 'package:flutter/material.dart';

import 'mobile/analytics_mobile_screen.dart';
import '../desktop/analytics_desktop_screen.dart';

/// Routes to mobile or desktop analytics presentation by width.
class AnalyticsAdminScreen extends StatelessWidget {
  const AnalyticsAdminScreen({super.key});

  static const double _wideBreakpoint = 1024;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < _wideBreakpoint) {
          return const AnalyticsMobileScreen();
        }
        return const AnalyticsDesktopScreen();
      },
    );
  }
}
