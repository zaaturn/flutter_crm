import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/admin_dashboard/model/employee.dart';

// BLOC & STATE IMPORTS
import 'package:my_app/admin_dashboard/bloc/employee_list_bloc.dart';
import 'package:my_app/admin_dashboard/bloc/employee_list_event.dart';
import 'package:my_app/admin_dashboard/bloc/employee_list_state.dart';



import 'package:my_app/admin_dashboard/repository/employee_list_repository.dart';

import 'dashboard_card.dart';
import 'dashboard_item.dart';

import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/mainscreen/mobile_employee_section.dart';
import 'package:my_app/admin_dashboard/screen/device_specific/mobile_screen/mainscreen/employee_card_mobile.dart';

class DashboardGrid extends StatelessWidget {
  final List<Employee> employees;

  const DashboardGrid({super.key, required this.employees});

  @override
  Widget build(BuildContext context) {
    final items = [
      const DashboardItem(
        icon: Icons.dashboard_rounded,
        label: 'Dashboard',
        bgColor: Color(0xFFEFF3FF),
        iconColor: Color(0xFF3B82F6),
      ),

      DashboardItem(
        icon: Icons.badge_rounded,
        label: 'Employees',
        bgColor: const Color(0xFFECFDF5),
        iconColor: const Color(0xFF10B981),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => EmployeeListBloc(

                  repository: EmployeeRepository(),
                )..add(const FetchEmployees()),
                child: Scaffold(
                  backgroundColor: Colors.white,
                  appBar: AppBar(
                    title: const Text("Employee Directory"),
                    elevation: 0,
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0F172A),
                  ),
                  body: BlocBuilder<EmployeeListBloc, EmployeeListState>(
                    builder: (context, state) {
                      if (state.status == EmployeeListStatus.loading) {
                        return const Center(
                          child: CircularProgressIndicator(color: Color(0xFF10B981)),
                        );
                      }

                      if (state.status == EmployeeListStatus.failure) {

                        return Center(child: Text(state.errorMessage ?? "An error occurred"));
                      }

                      return MobileEmployeeSection(
                        employees: state.employeesWithStatus,
                        onEmployeeTap: (employee) {
                          final isOnline = state.liveStatusMap[employee.id] ?? false;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EmployeeCardMobile(
                                employee: employee,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),

      const DashboardItem(
        icon: Icons.assignment_rounded,
        label: 'Projects & Tasks',
        bgColor: Color(0xFFEEF2FF),
        iconColor: Color(0xFF6366F1),
      ),
      const DashboardItem(
        icon: Icons.share_rounded,
        label: 'Share',
        bgColor: Color(0xFFFFF1F2),
        iconColor: Color(0xFFF43F5E),
      ),
      const DashboardItem(
        icon: Icons.handshake_rounded,
        label: 'Clients',
        bgColor: Color(0xFFFFFBEB),
        iconColor: Color(0xFFF59E0B),
      ),
      const DashboardItem(
        icon: Icons.inventory_2_rounded,
        label: 'Assets & Resources',
        bgColor: Color(0xFFF0FDFA),
        iconColor: Color(0xFF14B8A6),
      ),
      const DashboardItem(
        icon: Icons.event_busy_rounded,
        label: 'Leave Management',
        bgColor: Color(0xFFFFF7ED),
        iconColor: Color(0xFFF97316),
      ),
      const DashboardItem(
        icon: Icons.receipt_long_rounded,
        label: 'Billing & Invoices',
        bgColor: Color(0xFFF5F3FF),
        iconColor: Color(0xFF8B5CF6),
      ),
      const DashboardItem(
        icon: Icons.payments_rounded,
        label: 'Payroll',
        bgColor: Color(0xFFECFEFF),
        iconColor: Color(0xFF06B6D4),
      ),
      const DashboardItem(
        icon: Icons.groups_3_rounded,
        label: 'Leads',
        bgColor: Color(0xFFF7FEE7),
        iconColor: Color(0xFF84CC16),
      ),
      const DashboardItem(
        icon: Icons.event_available_rounded,
        label: 'Events',
        bgColor: Color(0xFFFDF4FF),
        iconColor: Color(0xFFD946EF),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: 150,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return DashboardCard(item: items[index]);
      },
    );
  }
}