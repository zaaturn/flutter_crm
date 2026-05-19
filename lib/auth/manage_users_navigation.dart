import 'package:flutter/material.dart';

import 'package:my_app/auth/auth_session.dart';
import 'package:my_app/auth/screens/superadmin_users_screen.dart';
import 'package:my_app/services/secure_storage_service.dart';

/// Opens [SuperadminUsersScreen] only when stored session is superuser —
/// same gate as desktop [SidebarHandler] for [SidebarAction.superadminUsers].
Future<void> openManageUsersIfAllowed(BuildContext context) async {
  final raw = await SecureStorageService().readAuthSessionJson();
  if (!context.mounted) return;
  final session = AuthSession.fromStorageString(raw);
  if (session?.isSuperuser != true) {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limited access'),
        content: const Text(
          'Your admin account does not include user management. Contact a superadmin if you need access.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    return;
  }

  await Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => const SuperadminUsersScreen(),
    ),
  );
}
