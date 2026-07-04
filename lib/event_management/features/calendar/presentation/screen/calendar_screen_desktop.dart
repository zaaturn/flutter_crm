import 'package:flutter/material.dart';
import 'package:my_app/event_management/features/calendar/presentation/desktop/event_management_desktop_shell.dart';

/// Desktop entry — dashboard + calendar rail.
class CalendarScreenDesktop extends StatelessWidget {
  const CalendarScreenDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return const EventManagementDesktopShell();
  }
}
