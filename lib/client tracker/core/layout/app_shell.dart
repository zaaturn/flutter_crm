import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

// --- FEATURE IMPORTS ---
import '../../features/dashboard/screen/dashboard_screen.dart';
import '../../features/clients/screen/add_client_screen.dart';
import '../../features/clients/screen/client_list_screen.dart';
import 'package:my_app/client tracker/features/payment/screen/payment_tracker_screen.dart';
import '../../features/clients/bloc/client_bloc.dart';
import '../../features/clients/bloc/client_event.dart';

import 'package:my_app/admin_dashboard/screen/device_specific/admin_dashboard_desktop.dart';

class AppColors {
  static const Color brandPurple   = Color(0xFF7C3AED); // Main Purple
  static const Color sidebar       = Color(0xFF000000); // Deep Black
  static const Color sidebarActive = Color(0xFF1A1A1A); // Active Dark Grey
  static const Color bg            = Color(0xFFF8FAFC); // Light Slate BG
  static const Color surface       = Color(0xFFFFFFFF); // White
  static const Color border        = Color(0xFFEDE9FE); // Lavender Border
  static const Color textMain      = Color(0xFF0F172A); // Dark Slate
  static const Color textMuted     = Color(0xFF64748B); // Slate Grey
}

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

  void _handleBack() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const AdminDashboardDesktop()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Row(
        children: [

          _Sidebar(selected: _idx, onTap: _go),

          Expanded(
            child: Column(
              children: [
                _TopBar(
                  idx: _idx,
                  onAdd: () => _go(1),
                  onBack: _handleBack,
                ),
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
// TOP BAR (With Back Button & Purple Cap Button)
// ════════════════════════════════════════════════════
class _TopBar extends StatelessWidget {
  final int idx;
  final VoidCallback onAdd;
  final VoidCallback onBack;

  const _TopBar({
    required this.idx,
    required this.onAdd,
    required this.onBack,
  });

  static const _titles = ['Dashboard', 'Add New Client', 'All Clients', 'Payment Tracker'];
  static const _subs   = ['Overview of your Clients', 'Clients › Add Client', 'Clients › List', 'Finance › Monthly Payments'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1.5)),
      ),
      child: Row(
        children: [
          // ── BACK BUTTON ──
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textMain, size: 24),
            tooltip: 'Back to Admin Dashboard',
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _titles[idx],
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMain,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _subs[idx],
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const Spacer(),
          _PurpleCrmButton(label: '+ Add Client', onTap: onAdd),
        ],
      ),
    );
  }
}

class _PurpleCrmButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _PurpleCrmButton({required this.label, required this.onTap});

  @override
  State<_PurpleCrmButton> createState() => _PurpleCrmButtonState();
}

class _PurpleCrmButtonState extends State<_PurpleCrmButton> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit:  (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: _hover ? const Color(0xFF6D28D9) : AppColors.brandPurple,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.brandPurple.withOpacity(0.2),
                blurRadius: 12, offset: const Offset(0, 4),
              )
            ],
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════
// SIDEBAR (Deep Black & Rounded Highlights)
// ════════════════════════════════════════════════════
class _Sidebar extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onTap;
  const _Sidebar({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Container(
        color: AppColors.sidebar,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
              child: Row(
                children: [
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.auto_awesome_motion_rounded, color: AppColors.brandPurple, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Client Tracker', style: GoogleFonts.plusJakartaSans(
                          color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                      Text('Daxarrow ', style: GoogleFonts.plusJakartaSans(
                          color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),

            // Navigation Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                children: [
                  _label('MAIN'),
                  _tile(0, Icons.grid_view_rounded, 'Dashboard', null),
                  const SizedBox(height: 12),
                  _label('CLIENTS'),
                  _tile(1, Icons.person_add_alt_1_rounded, 'Add Client', null),
                  _tile(2, Icons.group_rounded, 'All Clients',null),
                  const SizedBox(height: 12),
                  _label('FINANCE'),
                  _tile(3, Icons.account_balance_wallet_rounded, 'Payment Tracker', null),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
    child: Text(text, style: GoogleFonts.plusJakartaSans(
        color: Colors.white24, fontSize: 10,
        fontWeight: FontWeight.w800, letterSpacing: 1.5)),
  );

  Widget _tile(int idx, IconData icon, String label, String? badge) {
    return _SidebarTile(
      idx: idx, icon: icon, label: label, badge: badge,
      selected: selected, onTap: onTap,
    );
  }
}

class _SidebarTile extends StatefulWidget {
  final int idx, selected;
  final IconData icon;
  final String label;
  final String? badge;
  final ValueChanged<int> onTap;

  const _SidebarTile({
    required this.idx, required this.selected,
    required this.icon, required this.label,
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
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: active
                ? AppColors.sidebarActive
                : _hover ? Colors.white.withOpacity(0.05) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                  widget.icon,
                  size: 20,
                  color: active ? AppColors.brandPurple : Colors.white54
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(widget.label,
                    style: GoogleFonts.plusJakartaSans(
                      color: active ? Colors.white : Colors.white60,
                      fontSize: 14,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    )),
              ),
              if (widget.badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.brandPurple.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(widget.badge!, style: GoogleFonts.plusJakartaSans(
                      color: AppColors.brandPurple, fontSize: 10, fontWeight: FontWeight.w800)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}