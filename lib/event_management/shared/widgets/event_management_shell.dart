import 'package:flutter/material.dart';
import 'package:my_app/core/ui/adaptive_layout.dart';
import 'package:my_app/event_management/features/calendar/presentation/desktop/event_management_desktop_shell.dart';
import 'package:my_app/event_management/features/calendar/presentation/mobile/event_management_mobile_shell.dart';

/// Routes to mobile calendar-only shell or desktop dashboard + calendar shell.
class EventManagementShell extends StatelessWidget {
  const EventManagementShell({super.key});

  @override
  Widget build(BuildContext context) {
    if (AdaptiveLayout.useMobileUi(context)) {
      return const EventManagementMobileShell(showBackButton: true);
    }
    return const EventManagementDesktopShell();
  }
}
