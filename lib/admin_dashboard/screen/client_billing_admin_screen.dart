import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_app/admin_dashboard/cubit/client_dashboard_summary_cubit.dart';
import 'package:my_app/admin_dashboard/cubit/client_dashboard_summary_state.dart';
import 'package:my_app/admin_dashboard/presentation/mobile/client_billing/client_billing_mobile_dashboard.dart';
import 'package:my_app/admin_dashboard/shared/admin_dashboard_theme.dart';
import 'package:my_app/admin_dashboard/widget/device_specific/admin_client_summary_panel.dart';

class ClientBillingAdminScreen extends StatelessWidget {
  const ClientBillingAdminScreen({super.key});

  static const double _lgBreakpoint = 1024;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ClientDashboardSummaryCubit, ClientDashboardSummaryState>(
      listenWhen: (p, c) => p.toastError != c.toastError,
      listener: (context, state) {
        final msg = state.toastError;
        if (msg != null && msg.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: const Color(0xFFC05C39),
            ),
          );
        }
      },
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= _lgBreakpoint;
            if (!wide) {
              return const ClientBillingMobileDashboard();
            }
            return Scaffold(
              backgroundColor: AdminDashboardTheme.shellMint,
              appBar: AppBar(
                backgroundColor: AdminDashboardTheme.shellMint,
                elevation: 0,
                scrolledUnderElevation: 0,
                surfaceTintColor: Colors.transparent,
                title: const Text('Client Billing'),
              ),
              body: const Padding(
                padding: EdgeInsets.all(AdminDashboardTheme.shellPadding),
                child: AdminClientSummaryPanel(separatePanels: true),
              ),
            );
          },
        );
      },
    );
  }
}
