import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/auth/auth_session.dart';
import 'package:my_app/services/secure_storage_service.dart';

import '../bloc/analytics_bloc.dart';
import '../bloc/analytics_event.dart';
import '../repository/analytics_repository.dart';
import '../presentation/screen/analytics_admin_screen.dart';

class AnalyticsFlowController {
  static const String moduleKey = 'analytics';

  static Future<bool> _sessionAllows() async {
    final raw = await SecureStorageService().readAuthSessionJson();
    final session = AuthSession.fromStorageString(raw);
    if (session == null) return false;
    if (session.isSuperuser) return true;
    return session.adminModules[moduleKey] == true;
  }

  static Future<void> openWithPermissionCheck(BuildContext context) async {
    final allowed = await _sessionAllows();
    if (!context.mounted) return;
    if (!allowed) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Limited access'),
          content: const Text(
            'Your admin account does not include Analytics. '
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
    await open(context);
  }

  static Future<void> open(BuildContext context) async {
    await Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => AnalyticsBloc(
            repository: AnalyticsRepository(),
          )..add(const AnalyticsStarted()),
          child: const AnalyticsAdminScreen(),
        ),
      ),
    );
  }
}
