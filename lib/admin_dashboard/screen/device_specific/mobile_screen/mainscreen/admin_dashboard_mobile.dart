import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/admin_dashboard/bloc/admin_dashboard_bloc.dart';
import 'package:my_app/admin_dashboard/bloc/admin_dashboard_event.dart';
import 'package:my_app/admin_dashboard/repository/admin_repository.dart';

import 'dashboard_view.dart';

class AdminDashboardMobile extends StatelessWidget {
  const AdminDashboardMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminDashboardBloc(
        repository: AdminRepository(),
      )
        ..add(const AdminDashboardStarted())
        ..add(const RegisterAdminNotificationDevice()),
      child: const DashboardView(),
    );
  }
}