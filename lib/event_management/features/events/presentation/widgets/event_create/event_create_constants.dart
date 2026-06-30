import 'package:flutter/material.dart';

import 'package:my_app/event_management/features/dashboard/shared/dashboard_ui_theme.dart';

/// Layout and copy shared by the event composer screen.
abstract final class EventCreateLayout {
  static const double wideBreakpoint = 880;
  static const double maxContentWidth = 1120;
  static const Color surfaceColor = DashboardUiTheme.pageBackground;
  static const String brandTitle = 'Create Event';
}
