import 'package:flutter/material.dart';

import 'package:my_app/admin_dashboard/shared/admin_dashboard_theme.dart';
import 'package:my_app/employee_dashboard/widget/device_specific/v2/employee_dashboard_v2_theme.dart';

/// Desktop admin survey UI aligns with admin dashboard mint shell.
/// Mobile employee flows can still use [SurveyMobileTheme].
class SurveyTheme {
  SurveyTheme._();

  static const shell = AdminDashboardTheme.shellMint;
  static const background = AdminDashboardTheme.surface;
  static const surface = AdminDashboardTheme.surfaceMuted;
  static const surfaceAlt = AdminDashboardTheme.iconRailBg;
  static const divider = AdminDashboardTheme.border;
  static const border = AdminDashboardTheme.border;

  static const textMain = AdminDashboardTheme.textDark;
  static const textMuted = AdminDashboardTheme.textMuted;

  static const primary = AdminDashboardTheme.teal;
  static const primaryDark = AdminDashboardTheme.tealDark;
  static const primaryLight = AdminDashboardTheme.tealLight;
  static const accentYellow = AdminDashboardTheme.accentYellow;

  /// Legacy aliases used across survey widgets.
  static const purple = primary;
  static const purpleDark = primaryDark;
  static const purpleLight = primaryLight;

  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);

  /// Employee take-survey desktop shell (mint, matches employee v2).
  static const employeeShell = EmployeeDashboardV2Theme.shell;

  static Color statusColor(SurveyStatusLike status) {
    switch (status) {
      case SurveyStatusLike.draft:
        return textMuted;
      case SurveyStatusLike.active:
        return success;
      case SurveyStatusLike.closed:
        return primaryDark;
    }
  }
}

enum SurveyStatusLike { draft, active, closed }

SurveyStatusLike statusLikeFromString(String? s) {
  switch (s?.toLowerCase()) {
    case 'draft':
      return SurveyStatusLike.draft;
    case 'active':
      return SurveyStatusLike.active;
    case 'closed':
      return SurveyStatusLike.closed;
    default:
      return SurveyStatusLike.draft;
  }
}
