import 'package:flutter/material.dart';

import 'package:my_app/auth/auth_session.dart';
import 'package:my_app/core/auth/shell_route_persistence.dart';
import 'package:my_app/services/secure_storage_service.dart';

/// Blocks employees (and other non-admin roles) from the admin dashboard shell.
abstract final class AdminAccessGuard {
  static Future<AuthSession?> readStoredSession() async {
    final raw = await SecureStorageService().readAuthSessionJson();
    return AuthSession.fromStorageString(raw);
  }

  static bool allows({
    AuthSession? session,
    String? role,
    bool legacySuperuser = false,
  }) {
    if (session != null) return session.canAccessAdminDashboard;
    if (legacySuperuser) return true;
    return (role ?? 'employee').toLowerCase() == 'admin';
  }

  static Future<bool> allowsCurrentUser() async {
    final storage = SecureStorageService();
    final session = await readStoredSession();
    if (session != null) return session.canAccessAdminDashboard;
    final role = await storage.readRole();
    final legacySuperuser = await storage.readIsSuperuser();
    return allows(role: role, legacySuperuser: legacySuperuser);
  }

  /// Returns `false` and redirects to the employee shell when access is denied.
  static Future<bool> ensureAccess(BuildContext context) async {
    if (await allowsCurrentUser()) return true;
    await ShellRoutePersistence.markEmployeeShell();
    if (!context.mounted) return false;
    Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
      ShellRoutePersistence.employee,
      (_) => false,
    );
    return false;
  }
}

/// Wraps admin-only routes; redirects employees to the employee dashboard.
class AdminRouteGuard extends StatefulWidget {
  const AdminRouteGuard({super.key, required this.child});

  final Widget child;

  @override
  State<AdminRouteGuard> createState() => _AdminRouteGuardState();
}

class _AdminRouteGuardState extends State<AdminRouteGuard> {
  bool _allowed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _verify());
  }

  Future<void> _verify() async {
    final ok = await AdminAccessGuard.ensureAccess(context);
    if (!mounted) return;
    if (ok) setState(() => _allowed = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_allowed) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return widget.child;
  }
}
