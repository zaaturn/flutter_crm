import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/admin_dashboard/bloc/admin_dashboard_bloc.dart';
import 'package:my_app/admin_dashboard/bloc/admin_dashboard_event.dart';
import 'package:my_app/admin_dashboard/bloc/employee_list_bloc.dart';
import 'package:my_app/admin_dashboard/presentation/mobile/mobile_dashboard_shell.dart';
import 'package:my_app/admin_dashboard/repository/admin_repository.dart';
import 'package:my_app/admin_dashboard/repository/employee_list_repository.dart';

class AdminDashboardMobile extends StatelessWidget {
  const AdminDashboardMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AdminDashboardBloc(
            repository: AdminRepository(),
          )
            ..add(const AdminDashboardStarted())
            ..add(const RegisterAdminNotificationDevice()),
        ),
        BlocProvider(
          create: (_) => EmployeeListBloc(
            repository: EmployeeRepository(),
          ),
        ),
      ],
      child: const MobileDashboardShell(),
    );
  }
}
