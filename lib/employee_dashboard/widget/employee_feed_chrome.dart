import 'package:flutter/material.dart';
import 'package:my_app/leave_management/screens/mobile_screen/widget/leave_manager_colors.dart';

/// Employee dashboard feed-related accents: indigo on narrow (mobile), CRM
/// purple on wide (desktop employee layout).
class EmployeeFeedChrome {
  final Color accent;
  final Color accentLight;
  final Color borderAccent;

  const EmployeeFeedChrome._(this.accent, this.accentLight, this.borderAccent);

  factory EmployeeFeedChrome.of(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 900;
    if (narrow) {
      return EmployeeFeedChrome._(
        LeaveManagerColors.primary,
        const Color(0xFFEFF3FF),
        LeaveManagerColors.outlineVariant.withValues(alpha: 0.55),
      );
    }
    return const EmployeeFeedChrome._(
      Color(0xFF7C3AED),
      Color(0xFFF5F3FF),
      Color(0xFFEDE9FE),
    );
  }
}
