import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_app/core/auth/auth_session_redirect.dart';
import 'package:my_app/employee_dashboard/bloc/employee_dashboard_bloc.dart';
import 'package:my_app/employee_dashboard/bloc/employee_dashboard_event.dart';

/// Confirms and performs employee desktop logout (shared across v2 screens).
Future<void> confirmEmployeeDesktopLogout(BuildContext context) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Logout'),
      content: const Text('Are you sure you want to logout?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Logout'),
        ),
      ],
    ),
  );

  if (confirm != true || !context.mounted) return;

  await AuthSessionRedirect.logoutAndGoToLogin(
    context: context,
    beforeNavigate: () async {
      try {
        context.read<EmployeeBloc>().add(StopTaskPolling());
      } catch (_) {}
    },
  );
}
