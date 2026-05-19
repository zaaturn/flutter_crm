import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';


import 'package:my_app/client tracker/features/clients/bloc/dashboard_bloc.dart';
import 'package:my_app/client tracker/features/payment/bloc/payment_bloc.dart';
import 'package:my_app/client tracker/features/clients/bloc/dashboard_event.dart';
import 'package:my_app/client tracker/features/clients/bloc/dashboard_state.dart';
import 'package:my_app/client tracker/features/clients/repository/dashboard_repository.dart';
import 'package:my_app/client tracker/features/payment/repository/payment_repository.dart';


import 'client_tracker_mobile_add_client.dart';
import 'client_tracker_mobile_clients_list.dart';
import 'client_tracker_mobile_payments.dart';

// --- THE SHELL (MAIN WRAPPER) ---
class ClientTrackerMobileShell extends StatefulWidget {
  const ClientTrackerMobileShell({super.key});

  @override
  State<ClientTrackerMobileShell> createState() => _ClientTrackerMobileShellState();
}

class _ClientTrackerMobileShellState extends State<ClientTrackerMobileShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    const Color lightCream = Color(0xFFFAF9F6);

    return Scaffold(
      backgroundColor: lightCream,
      extendBody: true,
      body: IndexedStack(
        index: _tab,
        children: [
          const ClientTrackerMobileDashboard(),
          const ClientTrackerMobileAddClient(),
          const ClientTrackerMobileClientsList(),

          BlocProvider(
            create: (_) => PaymentBloc( PaymentRepository()),
            child: const ClientTrackerMobilePayments(),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
      ),
    );
  }
}

// --- THE DASHBOARD ---
class ClientTrackerMobileDashboard extends StatelessWidget {
  const ClientTrackerMobileDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardBloc(DashboardRepository())..add(LoadDashboardEvent()),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    const Color lightCream = Color(0xFFFAF9F6);
    const Color darkSlate = Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: lightCream,
      appBar: AppBar(
        backgroundColor: lightCream,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: darkSlate, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Client Tracker',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w900, color: darkSlate),
        ),
      ),
      body: RefreshIndicator(
        color: const Color(0xFFB35A38),
        onRefresh: () async {
          context.read<DashboardBloc>().add(LoadDashboardEvent());
        },
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFFB35A38)));
            }
            if (state is DashboardLoaded) {
              final d = state.data;
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
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
                  _BentoGrid(
                    totalClients: d.totalClients,
                    activeServices: d.activeServices,
                    invoicesSent: d.invoicesSent,
                    paymentsReceived: d.paymentsReceived,
                  ),
                  const SizedBox(height: 24),
                  _RecentClientsSection(list: d.recentClients),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

// --- BENTO GRID (SQUARE 2x2) ---
class _BentoGrid extends StatelessWidget {
  final int totalClients, activeServices, invoicesSent, paymentsReceived;
  const _BentoGrid({required this.totalClients, required this.activeServices, required this.invoicesSent, required this.paymentsReceived});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _StatSquare(label: 'Total\nClients', value: '$totalClients', icon: Icons.groups_rounded, bgColor: const Color(0xFFCED183)),
            const SizedBox(width: 12),
            _StatSquare(label: 'Active\nServices', value: '$activeServices', icon: Icons.auto_graph_rounded, bgColor: const Color(0xFFD7DEE6)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _StatSquare(label: 'Invoices\nSent', value: '$invoicesSent', icon: Icons.receipt_long_rounded, bgColor: const Color(0xFFF49F9A)),
            const SizedBox(width: 12),
            _StatSquare(label: 'Payments\nReceived', value: '$paymentsReceived', icon: Icons.payments_rounded, bgColor: const Color(0xFFEED397)),
          ],
        ),
      ],
    );
  }
}

class _StatSquare extends StatelessWidget {
  final String label, value; final IconData icon; final Color bgColor;
  const _StatSquare({required this.label, required this.value, required this.icon, required this.bgColor});

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
                decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                child: Icon(icon, color: darkText, size: 22),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.w900, color: darkText)),
                  Text(label, style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w800, height: 1.1, color: darkText.withOpacity(0.6))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- RECENT CLIENTS (TERRACOTTA) ---
class _RecentClientsSection extends StatelessWidget {
  final List<dynamic> list;
  const _RecentClientsSection({required this.list});

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
            child: Text('Recent Clients', style: GoogleFonts.manrope(fontSize: 17, fontWeight: FontWeight.w900, color: darkSlate)),
          ),
          if (list.isEmpty)
            Padding(padding: const EdgeInsets.all(20), child: Text('No recent clients yet.', style: GoogleFonts.manrope(color: darkSlate.withOpacity(0.5)))),
          ...list.take(5).map((c) => ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            leading: CircleAvatar(
              backgroundColor: terracotta.withOpacity(0.12),
              child: Text(c['name']?[0].toUpperCase() ?? '?', style: const TextStyle(fontWeight: FontWeight.w900, color: terracotta)),
            ),
            title: Text(c['name'] ?? 'Unknown', style: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: darkSlate)),
            subtitle: Text(c['category'] ?? 'General', style: GoogleFonts.manrope(fontSize: 12, color: darkSlate.withOpacity(0.5))),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: terracotta),
          )),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

// --- MASTER NAVIGATION BAR (PASTEL BLUE) ---
class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomBottomNav({super.key, required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const Color pastelBlue = Color(0xFFC1DBE8);
    const Color activeColor = Color(0xFF0F172A);
    const Color inactiveColor = Color(0xFF64748B);

    final items = [
      _NavData(Icons.dashboard_outlined, Icons.dashboard_rounded, 'DASH'),
      _NavData(Icons.person_add_alt_outlined, Icons.person_add_alt_1_rounded, 'ADD'),
      _NavData(Icons.groups_outlined, Icons.groups_rounded, 'CLIENTS'),
      _NavData(Icons.payments_outlined, Icons.payments_rounded, 'BILLING'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: pastelBlue,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [BoxShadow(color: activeColor.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final isSelected = selectedIndex == index;
              return InkWell(
                onTap: () => onTap(index),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white.withOpacity(0.4) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(isSelected ? items[index].active : items[index].normal, size: 24, color: isSelected ? activeColor : inactiveColor),
                      const SizedBox(height: 4),
                      Text(items[index].label, style: GoogleFonts.manrope(fontSize: 10, fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700, color: isSelected ? activeColor : inactiveColor)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavData {
  final IconData normal, active; final String label;
  _NavData(this.normal, this.active, this.label);
}