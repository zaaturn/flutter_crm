import 'package:flutter/material.dart';

import 'package:my_app/auth/auth_session.dart';
import 'package:my_app/services/secure_storage_service.dart';

import '../bloc/asset_event.dart';
import '../shared/asset_management_shell.dart';

class AssetFlowController {
  /// Opens the **admin** Assets & Resources module.
  static Future<void> openAdmin(
    BuildContext context, {
    AssetShellTab? initialTab,
  }) async {
    final raw = await SecureStorageService().readAuthSessionJson();
    if (!context.mounted) return;
    final session = AuthSession.fromStorageString(raw);

    if (session != null && !session.moduleAllowed('assets')) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Limited access'),
          content: const Text(
            'Your admin account does not include the Assets module. '
            'Contact a superadmin if you need access.',
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

    await Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => AssetAdminShell(initialTab: initialTab),
      ),
    );
  }

  /// Opens the **employee** My Assets module (scan / request / return).
  static Future<void> openEmployee(
    BuildContext context, {
    AssetShellTab? initialTab,
  }) async {
    await Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => AssetEmployeeShell(initialTab: initialTab),
      ),
    );
  }

  /// Prefer [openAdmin] / [openEmployee]. Kept for older call sites.
  static Future<void> open(
    BuildContext context, {
    AssetShellTab? initialTab,
    bool? forceAdmin,
  }) async {
    if (forceAdmin == true) {
      return openAdmin(context, initialTab: initialTab);
    }
    if (forceAdmin == false) {
      return openEmployee(context, initialTab: initialTab);
    }

    final role = await SecureStorageService().readRole();
    final lastShell = await SecureStorageService().readLastShellRoute();
    if (!context.mounted) return;

    final onAdminShell = lastShell == '/adminDashboard' ||
        (role ?? '').toLowerCase() == 'admin';

    if (onAdminShell) {
      return openAdmin(context, initialTab: initialTab);
    }
    return openEmployee(context, initialTab: initialTab);
  }

  static Future<void> openPendingRequests(BuildContext context) =>
      openAdmin(context, initialTab: AssetShellTab.pendingRequests);

  static Future<void> openPendingReturns(BuildContext context) =>
      openAdmin(context, initialTab: AssetShellTab.pendingReturns);

  static Future<void> openPendingDamage(BuildContext context) =>
      openAdmin(context, initialTab: AssetShellTab.pendingDamage);

  static Future<void> openDashboard(BuildContext context) =>
      openAdmin(context, initialTab: AssetShellTab.dashboard);

  static Future<void> openMyAssets(BuildContext context) =>
      openEmployee(context, initialTab: AssetShellTab.myAssets);
}
