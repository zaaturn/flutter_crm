import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/client tracker/core/constants/app_theme.dart';
import 'package:my_app/client tracker/core/constants/crm_widget.dart';
import '../../features/dashboard/screen/dashboard_screen.dart';
import '../../features/clients/screen/add_client_screen.dart';
import '../../features/clients/screen/client_list_screen.dart';
import 'package:my_app/client tracker/features/payment/screen/payment_tracker_screen.dart';
import '../../features/clients/bloc/client_bloc.dart';
import '../../features/clients/bloc/client_event.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _idx = 0;

  Widget _page() {
    switch (_idx) {
      case 0: return const DashboardScreen();
      case 1: return const AddClientScreen();
      case 2: return const ClientListScreen();
      case 3: return const PaymentTrackerScreen();
      default: return const DashboardScreen();
    }
  }

  void _go(int i) {
    setState(() => _idx = i);
    if (i == 2) context.read<ClientBloc>().add(LoadClientsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Row(
        children: [
          // ── SIDEBAR always visible ──────────────
          _Sidebar(selected: _idx, onTap: _go),
          // ── CONTENT ────────────────────────────
          Expanded(
            child: Column(
              children: [
                _TopBar(idx: _idx, onAdd: () => _go(1)),
                Expanded(child: _page()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════
// TOP BAR
// ════════════════════════════════════════════════════
class _TopBar extends StatelessWidget {
  final int idx;
  final VoidCallback onAdd;
  const _TopBar({required this.idx, required this.onAdd});

  static const _titles = ['Dashboard', 'Add New Client', 'All Clients', 'Payment Tracker'];
  static const _subs   = ['Overview of your Clients', 'Clients › Add Client', 'Clients › List', 'Finance › Monthly Payments'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_titles[idx], style: AppTextStyles.subheading),
              Text(_subs[idx],   style: AppTextStyles.small),
            ],
          ),
          const Spacer(),
          CrmButton('+ Add Client', onTap: onAdd),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════
// SIDEBAR
// ════════════════════════════════════════════════════
class _Sidebar extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onTap;
  const _Sidebar({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 248,
      child: Container(
        color: AppColors.sidebar,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo
            Container(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0x1AFFFFFF))),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(
                        color: AppColors.primary.withOpacity(.4),
                        blurRadius: 12, offset: const Offset(0, 4),
                      )],
                    ),
                    alignment: Alignment.center,
                    child: const Text('🏢', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Client Tracker', style: GoogleFonts.plusJakartaSans(
                          color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                      Text('Track Your Client', style: GoogleFonts.plusJakartaSans(
                          color: Colors.white38, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),

            // Nav items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                children: [
                  _label('MAIN'),
                  _tile(0, '📊', 'Dashboard',      null),
                  _label('CLIENTS'),
                  _tile(1, '➕', 'Add Client',      null),
                  _tile(2, '👥', 'All Clients',null),
                  _label('FINANCE'),
                  _tile(3, '💳', 'Payment Tracker', null),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(10, 14, 10, 6),
    child: Text(text, style: GoogleFonts.plusJakartaSans(
        color: Colors.white30, fontSize: 10,
        fontWeight: FontWeight.w700, letterSpacing: 1.2)),
  );

  Widget _tile(int idx, String emoji, String label, String? badge) {
    return _SidebarTile(
      idx: idx, emoji: emoji, label: label, badge: badge,
      selected: selected, onTap: onTap,
    );
  }
}

class _SidebarTile extends StatefulWidget {
  final int idx, selected;
  final String emoji, label;
  final String? badge;
  final ValueChanged<int> onTap;

  const _SidebarTile({
    required this.idx, required this.selected,
    required this.emoji, required this.label,
    required this.badge, required this.onTap,
  });

  @override
  State<_SidebarTile> createState() => _SidebarTileState();
}

class _SidebarTileState extends State<_SidebarTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.selected == widget.idx;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit:  (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => widget.onTap(widget.idx),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: active
                ? AppColors.sidebarActive
                : _hover ? const Color(0x18FFFFFF) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: active
                ? const Border(left: BorderSide(color: AppColors.primary, width: 3))
                : null,
          ),
          child: Row(
            children: [
              Text(widget.emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(widget.label,
                    style: GoogleFonts.plusJakartaSans(
                      color: active ? Colors.white : Colors.white60,
                      fontSize: 13.5,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                    )),
              ),
              if (widget.badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(widget.badge!, style: GoogleFonts.plusJakartaSans(
                      color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}