import 'package:flutter/material.dart';
import 'package:my_app/leave_management/screens/mobile_screen/widget/leave_manager_colors.dart';

/// Theme tokens for Client Tracker mobile, aligned with Leave Manager.
abstract final class ClientTrackerMobileTheme {
  static const Color bg = LeaveManagerColors.background;
  static const Color surface = LeaveManagerColors.surface;
  static const Color primary = LeaveManagerColors.primary;
  static const Color primaryDark = LeaveManagerColors.primaryDark;
  static const Color text = LeaveManagerColors.onBackground;
  static const Color muted = LeaveManagerColors.outline;
  static const Color border = Color(0xFFE2E8F0);

  /// Soft indigo tint for nested rows (aligned with billing mobile chip bg).
  static const Color primarySoftSurface = Color(0xFFEFF3FF);

  static BoxDecoration cardDecoration() => BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      );
}

