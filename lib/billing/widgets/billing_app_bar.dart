import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/billing_theme.dart';
import '../theme/billing_adaptive_theme.dart';

PreferredSizeWidget billingAppBar({
  required String title,
  required VoidCallback onBack,
  List<Widget>? actions,
}) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(kToolbarHeight + 1),
    child: Builder(
      builder: (context) {
        final bool isMobile = BillingAdaptiveTheme.isMobile(context);


        const Color inkText = Color(0xFF1A1C1E);
        const Color paperWhite = Color(0xFFFFFDFB);

        return AppBar(
          backgroundColor: isMobile ? paperWhite : BillingAdaptiveTheme.surface(context),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(
              isMobile ? Icons.arrow_back_ios_new_rounded : Icons.arrow_back_rounded,
              color: isMobile ? inkText : BillingAdaptiveTheme.text(context),
              size: isMobile ? 20 : 24,
            ),
            onPressed: onBack,
            tooltip: 'Back',
          ),
          title: Text(
            title,
            style: isMobile
                ? GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: inkText
            )
                : BillingTheme.titleAppBar().copyWith(
              color: BillingAdaptiveTheme.text(context),
            ),
          ),
          centerTitle: false,
          actions: actions,

          bottom: isMobile
              ? null
              : PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
                height: 1,
                color: BillingAdaptiveTheme.border(context)
            ),
          ),
        );
      },
    ),
  );
}