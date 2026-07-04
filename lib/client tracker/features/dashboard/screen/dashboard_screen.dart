import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/admin_dashboard/shared/admin_dashboard_theme.dart';
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
          return const Center(
            child: CircularProgressIndicator(color: AdminDashboardTheme.teal),
          );
        }

        if (state is DashboardLoaded) {
          final data = state.data;
          const gap = AdminDashboardTheme.panelGap;
          final stats = <({String label, String value, Color tint, Color accent})>[
            (
              label: 'Total Clients',
              value: '${data.totalClients}',
              tint: const Color(0xFFE8F4FD),
              accent: const Color(0xFF3B82F6),
            ),
            (
              label: 'Active Services',
              value: '${data.activeServices}',
              tint: const Color(0xFFECFDF5),
              accent: const Color(0xFF10B981),
            ),
            (
              label: 'Invoices Sent',
              value: '${data.invoicesSent}',
              tint: const Color(0xFFFFF7ED),
              accent: const Color(0xFFF59E0B),
            ),
            (
              label: 'Payments Received',
              value: '${data.paymentsReceived}',
              tint: const Color(0xFFF3E8FF),
              accent: const Color(0xFF7C3AED),
            ),
          ];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AdminDashboardTheme.shellPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < stats.length; i++)
                        Expanded(
                          child: AdminDashboardPanel(
                            margin: i < stats.length - 1
                                ? const EdgeInsets.only(right: gap)
                                : null,
                            child: _DashboardStatBox(
                              label: stats[i].label,
                              value: stats[i].value,
                              tint: stats[i].tint,
                              accent: stats[i].accent,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: gap),
                AdminDashboardPanel(
                  child: _RecentClients(clients: data.recentClients),
                ),
              ],
            ),
          );
        }

        if (state is DashboardError) {
          return AdminDashboardPanel(
            child: Center(child: Text(state.message)),
          );
        }

        return const SizedBox();
      },
    );
  }
}

class _DashboardStatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color tint;
  final Color accent;

  const _DashboardStatBox({
    required this.label,
    required this.value,
    required this.tint,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(AdminDashboardTheme.panelRadius - 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: accent,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: AdminDashboardTheme.textDark,
              letterSpacing: -1,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentClients extends StatelessWidget {
  final List<dynamic> clients;

  const _RecentClients({required this.clients});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(22, 16, 16, 14),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AdminDashboardTheme.border)),
          ),
          child: Row(
            children: [
              Text(
                'Recent Clients',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AdminDashboardTheme.textDark,
                ),
              ),
            ],
          ),
        ),
        if (clients.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No clients yet',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AdminDashboardTheme.textMuted,
              ),
            ),
          )
        else
          ...clients.map((c) => _ClientRow(client: c)),
      ],
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
        border: Border(bottom: BorderSide(color: AdminDashboardTheme.borderSoft)),
      ),
      child: Row(
        children: [
          ClientAvatar(
            name: client['name'] ?? '',
            gradient: const [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client['name'] ?? '',
                  style: AppTextStyles.bodyMed,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  client['category'] ?? '',
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
