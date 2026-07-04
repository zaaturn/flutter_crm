import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_app/admin_dashboard/cubit/client_dashboard_summary_cubit.dart';
import 'package:my_app/admin_dashboard/repository/client_dashboard_summary_repository.dart';
import 'package:my_app/admin_dashboard/screen/client_billing_admin_screen.dart';

class ClientBillingFlowController {
  static Future<void> open(BuildContext context) async {
    await Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => ClientDashboardSummaryCubit(
            ClientDashboardSummaryRepository(),
          )..initialize(),
          child: const ClientBillingAdminScreen(),
        ),
      ),
    );
  }
}
