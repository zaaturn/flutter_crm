import 'package:flutter/material.dart';
import 'package:my_app/event_management/shared/widgets/event_management_shell.dart';

/// Optional shell for embedding calendar + dashboard (e.g. standalone event module).
class AdaptiveScaffold extends StatelessWidget {
  final Widget child;

  const AdaptiveScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

/// Dashboard, Calendar, Notifications, and New event (same as [/calendar] route).
class EventModuleHome extends StatelessWidget {
  const EventModuleHome({super.key});

  @override
  Widget build(BuildContext context) => const EventManagementShell();
}
