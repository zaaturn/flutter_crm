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
import 'package:my_app/admin_dashboard/shared/admin_dashboard_theme.dart';

/// Kept for the few call sites in this file that reference it directly;
/// values now mirror [AdminDashboardTheme] so Client Tracker matches the
/// rest of the admin shell.
class AppColors {
  static const Color brandPurple   = AdminDashboardTheme.teal;
  static const Color sidebar       = AdminDashboardTheme.iconRailBg;
  static const Color sidebarActive = AdminDashboardTheme.accentYellow;
  static const Color bg            = AdminDashboardTheme.shellMint;
  static const Color surface       = AdminDashboardTheme.surface;
  static const Color border        = AdminDashboardTheme.border;
  static const Color textMain      = AdminDashboardTheme.textDark;
  static const Color textMuted     = AdminDashboardTheme.textMuted;
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
      backgroundColor: AdminDashboardTheme.shellMint,
      body: Padding(
        padding: const EdgeInsets.all(AdminDashboardTheme.shellPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AdminDashboardPanel(
              width: AdminDashboardTheme.railWidth,
              margin: const EdgeInsets.only(right: AdminDashboardTheme.panelGap),
              child: _Sidebar(selected: _idx, onTap: _go),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AdminDashboardPanel(
                    child: _TopBar(
                      idx: _idx,
                      onAdd: () => _go(1),
                      onBack: _handleBack,
                    ),
                  ),
                  const SizedBox(height: AdminDashboardTheme.panelGap),
                  Expanded(child: _page()),
                ],
              ),
            ),
          ],
        ),
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
  static const _subs   = ['', 'Clients › Add Client', 'Clients › List', 'Finance › Monthly Payments'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AdminDashboardTheme.surface,
        border: Border(bottom: BorderSide(color: AdminDashboardTheme.borderSoft, width: 1.5)),
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
              if (_subs[idx].isNotEmpty) ...[
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
            color: _hover ? AdminDashboardTheme.tealDark : AppColors.brandPurple,
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
// SIDEBAR — icon-only rail, matches the main dashboard's DesktopSidebar
// ════════════════════════════════════════════════════
class _Sidebar extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onTap;
  const _Sidebar({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 16, 10, 16),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AdminDashboardTheme.iconRailBg,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  children: [
                    _tile(0, Icons.grid_view_rounded, 'Dashboard'),
                    _tile(2, Icons.group_rounded, 'All Clients'),
                    _tile(3, Icons.account_balance_wallet_rounded, 'Payments'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(int pageIdx, IconData icon, String tooltip) {
    return _RailButton(
      icon: icon,
      tooltip: tooltip,
      selected: selected == pageIdx,
      onTap: () => onTap(pageIdx),
    );
  }
}

class _RailButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool selected;
  final VoidCallback onTap;

  const _RailButton({
    required this.icon,
    required this.tooltip,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? AdminDashboardTheme.textDark
        : AdminDashboardTheme.iconInactive;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Tooltip(
        message: tooltip,
        waitDuration: const Duration(milliseconds: 400),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AdminDashboardTheme.accentYellow : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 22, color: color),
            ),
          ),
        ),
      ),
    );
  }
}