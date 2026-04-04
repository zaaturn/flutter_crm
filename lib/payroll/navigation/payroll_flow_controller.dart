import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/payroll_dashboard_bloc.dart';
import '../bloc/payroll_dashboard_event.dart';
import '../repository/payroll_repository.dart';
import '../screen/payroll_admin_screen.dart';

class PayrollFlowController {
  static Future<void> open(BuildContext context) async {
    await Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute(
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
