import 'package:flutter/material.dart';
import 'package:my_app/event_management/shared/widgets/event_management_shell.dart';

/// Full Event Management area: Dashboard / Calendar / Events (same as admin).
class CalendarScreenDesktop extends StatelessWidget {
  const CalendarScreenDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return const EventManagementShell();
  }
}