import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/auth/auth_session.dart';
import 'package:my_app/services/secure_storage_service.dart';

import '../bloc/payroll_dashboard_bloc.dart';
import '../bloc/payroll_dashboard_event.dart';
import '../repository/payroll_repository.dart';
import '../screen/payroll_admin_screen.dart';

class PayrollFlowController {
  /// Opens payroll after verifying [AuthSession.canAccessPayrollAdmin] (same rule as sidebar).
  static Future<void> openWithPermissionCheck(BuildContext context) async {
    final raw = await SecureStorageService().readAuthSessionJson();
    if (!context.mounted) return;
    final session = AuthSession.fromStorageString(raw);
    if (!(session?.canAccessPayrollAdmin ?? false)) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Limited access'),
          content: const Text(
            'Your admin account does not include this module. Contact a superadmin if you need access.',
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
    await open(context);
  }

  static Future<void> open(BuildContext context) async {
    await Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => PayrollDashboardBloc(
            repository: PayrollRepository(),
          )..add(const PayrollDashboardStarted()),
          child: const PayrollAdminScreen(),
        ),
      ),
    );
  }
}
