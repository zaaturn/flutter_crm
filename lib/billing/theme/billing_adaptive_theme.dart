import 'package:flutter/material.dart';
import 'billing_leave_mobile_theme.dart';
import 'billing_theme.dart';

abstract final class BillingAdaptiveTheme {
  static bool isMobile(BuildContext context) => MediaQuery.sizeOf(context).width < 840;

  static Color bg(BuildContext context) =>
      isMobile(context) ? BillingLeaveMobileTheme.bg : BillingTheme.scaffoldBg;

  static Color surface(BuildContext context) =>
      isMobile(context) ? BillingLeaveMobileTheme.surface : BillingTheme.surface;

  static Color primary(BuildContext context) =>
      isMobile(context) ? BillingLeaveMobileTheme.primary : BillingTheme.purple;

  // Linked to the Elite Blue for mobile consistency
  static Color primaryDark(BuildContext context) =>
      isMobile(context) ? BillingLeaveMobileTheme.primary : BillingTheme.purpleDark;

  // Linked to the Clay Tint for mobile surfaces
  static Color primaryLight(BuildContext context) =>
      isMobile(context) ? BillingLeaveMobileTheme.surfaceMuted : BillingTheme.purpleLight;

  static Color text(BuildContext context) =>
      isMobile(context) ? BillingLeaveMobileTheme.text : BillingTheme.textPrimary;

  static Color muted(BuildContext context) =>
      isMobile(context) ? BillingLeaveMobileTheme.muted : BillingTheme.textMuted;

  static Color border(BuildContext context) =>
      isMobile(context) ? BillingLeaveMobileTheme.border : BillingTheme.border;

  static BoxDecoration cardDecoration(BuildContext context, {bool highlighted = false}) {
    if (isMobile(context)) return BillingLeaveMobileTheme.cardDecoration();
    return BillingTheme.cardDecoration(highlighted: highlighted);
  }

  static ThemeData datePickerTheme(BuildContext context) {
    if (!isMobile(context)) return BillingTheme.datePickerTheme(context);
    final base = Theme.of(context);
    return base.copyWith(
      colorScheme: ColorScheme.light(
        primary: primary(context),
        onPrimary: Colors.white,
        surface: surface(context),
        onSurface: text(context),
      ),
    );
  }
}