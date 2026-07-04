import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/analytics_theme.dart';
import '../../mobile/mobile_analytics_body.dart';

/// Full-screen mobile analytics route (pushed from sidebar / modules).
class AnalyticsMobileScreen extends StatelessWidget {
  const AnalyticsMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: AnalyticsMobileTheme.background,
        textTheme: GoogleFonts.manropeTextTheme(Theme.of(context).textTheme),
      ),
      child: Scaffold(
        backgroundColor: AnalyticsMobileTheme.background,
        body: const SafeArea(
          child: MobileAnalyticsBody(showBackButton: true),
        ),
      ),
    );
  }
}
