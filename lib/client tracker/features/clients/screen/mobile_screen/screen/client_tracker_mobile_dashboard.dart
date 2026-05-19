import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:my_app/client tracker/features/clients/bloc/dashboard_bloc.dart';
import 'package:my_app/client tracker/features/clients/bloc/dashboard_event.dart';
import 'package:my_app/client tracker/features/clients/bloc/dashboard_state.dart';
import 'package:my_app/client tracker/features/clients/repository/dashboard_repository.dart';

import '../widget/client_tracker_mobile_top_bar.dart';

class ClientTrackerMobileDashboard extends StatelessWidget {
  const ClientTrackerMobileDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardBloc(DashboardRepository())..add(LoadDashboardEvent()),
      child: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    const Color lightCream = Color(0xFFFAF9F6);
    const Color darkSlate = Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: lightCream,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            ClientTrackerMobileTopBar(
              title: 'Client Tracker',
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFFB35A38), // Terracotta
                onRefresh: () async {
                  context.read<DashboardBloc>().add(LoadDashboardEvent());
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                  children: [
                    Text(
                      'Overview of your clients and billing.',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: darkSlate.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 20),
                    BlocBuilder<DashboardBloc, DashboardState>(
                      builder: (context, state) {
                        if (state is DashboardLoading || state is DashboardInitial) {
                          return const Padding(
                            padding: EdgeInsets.all(60),
                            child: Center(child: CircularProgressIndicator(color: Color(0xFFB35A38))),
                          );
                        }
                        if (state is DashboardError) {
                          return _ErrorCard(
                            message: state.message,
                            onRetry: () => context.read<DashboardBloc>().add(LoadDashboardEvent()),
                          );
                        }
                        if (state is DashboardLoaded) {
                          final d = state.data;
                          return Column(
                            children: [
                              _BentoGrid(
                                totalClients: d.totalClients,
                                activeServices: d.activeServices,
                                invoicesSent: d.invoicesSent,
                                paymentsReceived: d.paymentsReceived,
                              ),
                              const SizedBox(height: 24),
                              _RecentClients(list: d.recentClients),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BentoGrid extends StatelessWidget {
  const _BentoGrid({
    required this.totalClients,
    required this.activeServices,
    required this.invoicesSent,
    required this.paymentsReceived,
  });

  final int totalClients, activeServices, invoicesSent, paymentsReceived;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _StatSquare(
              label: 'Total\nClients',
              value: '$totalClients',
              icon: Icons.groups_rounded,
              bgColor: const Color(0xFFCED183), // Fizzy Lime
            ),
            const SizedBox(width: 12),
            _StatSquare(
              label: 'Active\nServices',
              value: '$activeServices',
              icon: Icons.auto_graph_rounded,
              bgColor: const Color(0xFFD7DEE6), // Morning Mist
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _StatSquare(
              label: 'Invoices\nSent',
              value: '$invoicesSent',
              icon: Icons.receipt_long_rounded,
              bgColor: const Color(0xFFF49F9A), // Coral Reef
            ),
            const SizedBox(width: 12),
            _StatSquare(
              label: 'Payments\nReceived',
              value: '$paymentsReceived',
              icon: Icons.payments_rounded,
              bgColor: const Color(0xFFEED397), // Golden Hour
            ),
          ],
        ),
      ],
    );
  }
}

class _StatSquare extends StatelessWidget {
  const _StatSquare({
    required this.label,
    required this.value,
    required this.icon,
    required this.bgColor,
  });

  final String label, value;
  final IconData icon;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    const Color darkText = Color(0xFF0F172A);

    return Expanded(
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: darkText.withOpacity(0.08), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: darkText.withOpacity(0.08), shape: BoxShape.circle),
                child: Icon(icon, color: darkText, size: 22),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.w900, color: darkText),
                  ),
                  Text(
                    label,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                      color: darkText.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentClients extends StatelessWidget {
  const _RecentClients({required this.list});
  final List<dynamic> list;

  @override
  Widget build(BuildContext context) {
    const Color terracotta = Color(0xFFB35A38);
    const Color midCream = Color(0xFFEBDDCF);
    const Color darkSlate = Color(0xFF0F172A);

    return Container(
      decoration: BoxDecoration(
        color: midCream,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: darkSlate.withOpacity(0.1), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Text(
              'Recent Clients',
              style: GoogleFonts.manrope(fontSize: 17, fontWeight: FontWeight.w900, color: darkSlate),
            ),
          ),
          if (list.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('No recent clients yet.', style: GoogleFonts.manrope(color: darkSlate.withOpacity(0.5))),
            )
          else
            ...list.take(6).map((c) {
              final name = (c['name'] ?? '').toString();
              final category = (c['category'] ?? '').toString();
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                leading: CircleAvatar(
                  backgroundColor: terracotta.withOpacity(0.12),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(fontWeight: FontWeight.w900, color: terracotta),
                  ),
                ),
                title: Text(name, style: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: darkSlate)),
                subtitle: Text(category, style: GoogleFonts.manrope(fontSize: 12, color: darkSlate.withOpacity(0.5))),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: terracotta),
              );
            }),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF991B1B))),
          TextButton(onPressed: onRetry, child: const Text('Retry', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}