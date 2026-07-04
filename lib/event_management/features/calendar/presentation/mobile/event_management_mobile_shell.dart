import 'package:flutter/material.dart';

import 'event_calendar_mobile_screen.dart';

/// Mobile event management — calendar only (no dashboard tab).
class EventManagementMobileShell extends StatelessWidget {
  const EventManagementMobileShell({super.key, this.showBackButton = false});

  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return EventCalendarMobileScreen(showBackButton: showBackButton);
  }
}
