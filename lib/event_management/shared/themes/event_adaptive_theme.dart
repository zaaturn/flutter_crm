import 'package:flutter/material.dart';
import 'package:my_app/core/ui/adaptive_layout.dart';
import 'app_theme.dart';
import 'event_leave_mobile_theme.dart';

/// Adaptive theme for Event module:
/// - Mobile/narrow: Leave Management palette
/// - Wide: existing Event `AppTheme`
abstract final class EventAdaptiveTheme {
  static bool isMobile(BuildContext context) => AdaptiveLayout.useMobileUi(context);

  static Color bg(BuildContext context) =>
      isMobile(context) ? EventLeaveMobileTheme.bg : const Color(0xFFF8F9FB);

  static Color surface(BuildContext context) =>
      isMobile(context) ? EventLeaveMobileTheme.surface : Colors.white;

  static Color header(BuildContext context) =>
      isMobile(context) ? EventLeaveMobileTheme.header : Colors.white;

  static Color primary(BuildContext context) =>
      isMobile(context) ? EventLeaveMobileTheme.primary : AppTheme.primaryBlue;

  static Color text(BuildContext context) =>
      isMobile(context) ? EventLeaveMobileTheme.text : const Color(0xFF111827);

  static Color muted(BuildContext context) =>
      isMobile(context) ? EventLeaveMobileTheme.muted : const Color(0xFF6B7280);

  static Color border(BuildContext context) =>
      isMobile(context) ? EventLeaveMobileTheme.border : AppTheme.borderLight;
}

