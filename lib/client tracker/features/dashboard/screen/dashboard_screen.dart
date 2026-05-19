import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/client tracker/core/constants/app_theme.dart';
import 'package:my_app/client tracker/core/constants/crm_widget.dart';
import 'package:my_app/client tracker/features/clients/bloc/dashboard_event.dart';
import 'package:my_app/client tracker/features/clients/bloc/dashboard_bloc.dart';
import 'package:my_app/client tracker/features/clients/bloc/dashboard_state.dart';
import 'package:my_app/client tracker/features/clients/repository/dashboard_repository.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      DashboardBloc(DashboardRepository())..add(LoadDashboardEvent()),
      child: const _DashboardBody(),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {

        if (state is DashboardLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DashboardLoaded) {

          final data = state.data;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  'Welcome to Client Tracker Dashboard',
                  style: AppTextStyles.display,
                ),

                const SizedBox(height: 4),

                Text(
                  'Manage your clients, services and payments.',
                  style: AppTextStyles.small,
                ),

                const SizedBox(height: 24),

                /// STAT CARDS
                Row(
                  children: [

                    Expanded(
                      child: StatCard(
                        value: data.totalClients.toString(),
                        label: 'Total Clients',
                        valueColor: AppColors.primary,
                        iconBg: const Color(0xFFEBF5FB),
                        progress: .65,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: StatCard(
                        value: data.activeServices.toString(),
                        label: 'Active Services',
                        valueColor: AppColors.accent,
                        iconBg: const Color(0xFFE9F7EF),
                        progress: .80,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: StatCard(
                        value: data.invoicesSent.toString(),
                        label: 'Invoices Sent',
                        valueColor: AppColors.warn,
                        iconBg: const Color(0xFFFEF9E7),
                        progress: .75,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: StatCard(
                        value: data.paymentsReceived.toString(),
                        label: 'Payments Received',
                        valueColor: AppColors.danger,
                        iconBg: const Color(0xFFFDEDEC),
                        progress: .50,
                      ),
                    ),

                  ],
                ),

                const SizedBox(height: 24),

                /// RECENT CLIENTS FULL WIDTH
                _RecentClients(clients: data.recentClients),

              ],
            ),
          );
        }

        if (state is DashboardError) {
          return Center(child: Text(state.message));
        }

        return const SizedBox();
      },
    );
  }
}

////////////////////////////////////////////////////////////
/// RECENT CLIENTS
////////////////////////////////////////////////////////////

class _RecentClients extends StatelessWidget {

  final List<dynamic> clients;

  const _RecentClients({required this.clients});

  @override
  Widget build(BuildContext context) {
    return CrmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Container(
            padding: const EdgeInsets.fromLTRB(22, 16, 16, 14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Text('Recent Clients', style: AppTextStyles.subheading),
                const Spacer(),
                CrmButton('View All →', style: BtnStyle.ghost),
              ],
            ),
          ),

          ...clients.map((c) => _ClientRow(client: c)).toList(),

        ],
      ),
    );
  }
}

class _ClientRow extends StatelessWidget {

  final dynamic client;

  const _ClientRow({required this.client});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [

          ClientAvatar(
            name: client["name"] ?? "",
            gradient: const [Color(0xFF667eea), Color(0xFF764ba2)],
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  client["name"] ?? "",
                  style: AppTextStyles.bodyMed,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 2),

                Text(
                  client["category"] ?? "",
                  style: AppTextStyles.small,
                  overflow: TextOverflow.ellipsis,
                ),

              ],
            ),
          ),

        ],
      ),
    );
  }
}