import 'package:flutter/material.dart';
import 'package:my_app/event_management/features/calendar/presentation/mobile/event_management_mobile_shell.dart';

/// Mobile entry — calendar UI only (no dashboard bottom nav).
class CalendarScreenMobile extends StatelessWidget {
  const CalendarScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return const EventManagementMobileShell();
  }
}
