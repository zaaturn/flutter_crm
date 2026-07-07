import 'package:flutter/material.dart';

import 'package:my_app/admin_dashboard/shared/admin_dashboard_theme.dart';
import 'package:my_app/admin_dashboard/sidebar/device_specific/workspace_switcher_desktop.dart';

/// Round yellow workspace switch — matches admin dashboard header.
class EmployeeWorkspaceSwitchButton extends StatelessWidget {
  final BuildContext parentContext;

  const EmployeeWorkspaceSwitchButton({
    super.key,
    required this.parentContext,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Change workspace',
      child: Material(
        color: AdminDashboardTheme.accentYellow,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => WorkspaceSwitcherSheet.show(context, parentContext),
          child: const SizedBox(
            width: 42,
            height: 42,
            child: Icon(
              Icons.swap_horiz_rounded,
              size: 22,
              color: AdminDashboardTheme.textDark,
            ),
          ),
        ),
      ),
    );
  }
}
