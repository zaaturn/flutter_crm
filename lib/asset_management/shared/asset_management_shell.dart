import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:my_app/core/ui/adaptive_layout.dart';

import '../bloc/asset_bloc.dart';
import '../bloc/asset_event.dart';
import '../bloc/asset_state.dart';
import '../theme/asset_theme.dart';
import '../presentation/screens/asset_scan_screen.dart';
import '../presentation/screens/asset_tab_body.dart';

/// Admin-only Assets & Resources (dashboard, inventory, approvals).
class AssetAdminShell extends StatelessWidget {
  const AssetAdminShell({super.key, this.initialTab});

  final AssetShellTab? initialTab;

  static const tabs = <AssetShellTab>[
    AssetShellTab.dashboard,
    AssetShellTab.inventory,
    AssetShellTab.guests,
    AssetShellTab.pendingRequests,
    AssetShellTab.pendingReturns,
    AssetShellTab.pendingDamage,
    AssetShellTab.calendar,
    AssetShellTab.search,
  ];

  static const bottomTabs = <AssetShellTab>[
    AssetShellTab.dashboard,
    AssetShellTab.inventory,
    AssetShellTab.calendar,
    AssetShellTab.pendingRequests,
    AssetShellTab.pendingReturns,
  ];

  @override
  Widget build(BuildContext context) {
    final mobile = AdaptiveLayout.useMobileUi(context);
    final start = initialTab ?? AssetShellTab.dashboard;

    return BlocProvider(
      create: (_) => AssetBloc(isAdmin: true, initialTab: start)
        ..add(AssetShellStarted(isAdmin: true, initialTab: start)),
      child: mobile
          ? const _AssetRoleShell(
              isAdmin: true,
              useMobileTheme: true,
              title: 'Assets & Resources',
              tabs: tabs,
              bottomTabs: bottomTabs,
            )
          : const _AssetRoleShell(
              isAdmin: true,
              useMobileTheme: false,
              title: 'Assets & Resources',
              tabs: tabs,
              bottomTabs: bottomTabs,
            ),
    );
  }
}

/// Employee-only Assets (my assets, scan, search, calendar).
class AssetEmployeeShell extends StatelessWidget {
  const AssetEmployeeShell({super.key, this.initialTab});

  final AssetShellTab? initialTab;

  static const tabs = <AssetShellTab>[
    AssetShellTab.myAssets,
    AssetShellTab.scan,
    AssetShellTab.search,
    AssetShellTab.calendar,
  ];

  @override
  Widget build(BuildContext context) {
    final mobile = AdaptiveLayout.useMobileUi(context);
    final start = initialTab ?? AssetShellTab.myAssets;

    return BlocProvider(
      create: (_) => AssetBloc(isAdmin: false, initialTab: start)
        ..add(AssetShellStarted(isAdmin: false, initialTab: start)),
      child: mobile
          ? const _AssetRoleShell(
              isAdmin: false,
              useMobileTheme: true,
              title: 'My Assets',
              tabs: tabs,
              bottomTabs: tabs,
            )
          : const _AssetRoleShell(
              isAdmin: false,
              useMobileTheme: false,
              title: 'My Assets',
              tabs: tabs,
              bottomTabs: tabs,
            ),
    );
  }
}

/// @deprecated Use [AssetAdminShell] or [AssetEmployeeShell].
class AssetManagementShell extends StatelessWidget {
  const AssetManagementShell({
    super.key,
    required this.isAdmin,
    this.initialTab,
  });

  final bool isAdmin;
  final AssetShellTab? initialTab;

  @override
  Widget build(BuildContext context) {
    return isAdmin
        ? AssetAdminShell(initialTab: initialTab)
        : AssetEmployeeShell(initialTab: initialTab);
  }
}

class _AssetRoleShell extends StatelessWidget {
  const _AssetRoleShell({
    required this.isAdmin,
    required this.useMobileTheme,
    required this.title,
    required this.tabs,
    required this.bottomTabs,
  });

  final bool isAdmin;
  final bool useMobileTheme;
  final String title;
  final List<AssetShellTab> tabs;
  final List<AssetShellTab> bottomTabs;

  @override
  Widget build(BuildContext context) {
    if (!useMobileTheme) {
      return _DesktopShell(
        isAdmin: isAdmin,
        title: title,
        tabs: tabs,
      );
    }
    return _MobileShell(
      isAdmin: isAdmin,
      title: title,
      tabs: tabs,
      bottomTabs: bottomTabs,
    );
  }
}

class _DesktopShell extends StatelessWidget {
  const _DesktopShell({
    required this.isAdmin,
    required this.title,
    required this.tabs,
  });

  final bool isAdmin;
  final String title;
  final List<AssetShellTab> tabs;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AssetBloc, AssetState>(
      listenWhen: (p, c) =>
          p.error != c.error || p.successMessage != c.successMessage,
      listener: (context, state) {
        final msg = state.error ?? state.successMessage;
        if (msg == null) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      },
      child: Scaffold(
        backgroundColor: AssetDesktopTheme.shellMint,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 232,
                  decoration: BoxDecoration(
                    color: AssetDesktopTheme.teal,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AssetDesktopTheme.teal.withValues(alpha: 0.28),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                title,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          isAdmin ? 'Admin' : 'Employee',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withValues(alpha: 0.78),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                        child: Divider(
                          height: 1,
                          color: Colors.white.withValues(alpha: 0.22),
                        ),
                      ),
                      Expanded(
                        child: BlocBuilder<AssetBloc, AssetState>(
                          buildWhen: (p, c) => p.tab != c.tab,
                          builder: (context, state) {
                            return ListView(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              children: [
                                for (final tab in tabs)
                                  _NavTile(
                                    label: tab.label,
                                    icon: _iconFor(tab),
                                    selected: state.tab == tab,
                                    onTap: () => context
                                        .read<AssetBloc>()
                                        .add(AssetTabChanged(tab)),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AssetDesktopTheme.border),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: const AssetTabBody(useMobileTheme: false),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileShell extends StatelessWidget {
  const _MobileShell({
    required this.isAdmin,
    required this.title,
    required this.tabs,
    required this.bottomTabs,
  });

  final bool isAdmin;
  final String title;
  final List<AssetShellTab> tabs;
  final List<AssetShellTab> bottomTabs;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AssetBloc, AssetState>(
      listenWhen: (p, c) =>
          p.error != c.error || p.successMessage != c.successMessage,
      listener: (context, state) {
        final msg = state.error ?? state.successMessage;
        if (msg == null) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      },
      child: BlocBuilder<AssetBloc, AssetState>(
        builder: (context, state) {
          final bottomIndex = bottomTabs.indexOf(state.tab);
          final selectedIndex = bottomIndex >= 0 ? bottomIndex : 0;

          return Scaffold(
            backgroundColor: AssetMobileTheme.cream,
            appBar: AppBar(
              backgroundColor: AssetMobileTheme.terracotta,
              foregroundColor: Colors.white,
              elevation: 0,
              title: Text(
                state.tab.label,
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
              ),
              actions: [
                if (!isAdmin || state.tab == AssetShellTab.search)
                  IconButton(
                    tooltip: 'Scan QR',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              const AssetScanScreen(useMobileTheme: true),
                        ),
                      );
                    },
                    icon: const Icon(Icons.qr_code_scanner_rounded),
                  ),
              ],
            ),
            body: const AssetTabBody(useMobileTheme: true),
            bottomNavigationBar: NavigationBarTheme(
              data: NavigationBarThemeData(
                backgroundColor: AssetMobileTheme.terracotta,
                indicatorColor: Colors.white.withValues(alpha: 0.22),
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  final selected = states.contains(WidgetState.selected);
                  return GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: Colors.white.withValues(alpha: selected ? 1 : 0.78),
                  );
                }),
                iconTheme: WidgetStateProperty.resolveWith((states) {
                  final selected = states.contains(WidgetState.selected);
                  return IconThemeData(
                    size: 22,
                    color: Colors.white.withValues(alpha: selected ? 1 : 0.78),
                  );
                }),
              ),
              child: NavigationBar(
                backgroundColor: AssetMobileTheme.terracotta,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                height: 68,
                selectedIndex: selectedIndex.clamp(0, bottomTabs.length - 1),
                onDestinationSelected: (i) {
                  if (i < 0 || i >= bottomTabs.length) return;
                  context
                      .read<AssetBloc>()
                      .add(AssetTabChanged(bottomTabs[i]));
                },
                destinations: [
                  for (final tab in bottomTabs)
                    NavigationDestination(
                      icon: Icon(_iconFor(tab)),
                      selectedIcon: Icon(_iconFor(tab)),
                      label: _shortLabel(tab),
                    ),
                ],
              ),
            ),
            drawer: Drawer(
              backgroundColor: AssetMobileTheme.terracotta,
              child: SafeArea(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.inventory_2_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            title,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isAdmin ? 'Admin workspace' : 'Employee workspace',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white.withValues(alpha: 0.78),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.22),
                    ),
                    const SizedBox(height: 8),
                    for (final tab in tabs)
                      _DrawerTile(
                        label: tab.label,
                        icon: _iconFor(tab),
                        selected: state.tab == tab,
                        onTap: () {
                          Navigator.pop(context);
                          context.read<AssetBloc>().add(AssetTabChanged(tab));
                        },
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _shortLabel(AssetShellTab tab) {
    switch (tab) {
      case AssetShellTab.dashboard:
        return 'Home';
      case AssetShellTab.inventory:
        return 'Stock';
      case AssetShellTab.pendingRequests:
        return 'Requests';
      case AssetShellTab.pendingReturns:
        return 'Returns';
      case AssetShellTab.pendingDamage:
        return 'Damage';
      case AssetShellTab.myAssets:
        return 'Mine';
      case AssetShellTab.scan:
        return 'Scan';
      case AssetShellTab.search:
        return 'Search';
      case AssetShellTab.calendar:
        return 'Cal';
      case AssetShellTab.guests:
        return 'Guests';
    }
  }
}

IconData _iconFor(AssetShellTab tab) {
  switch (tab) {
    case AssetShellTab.dashboard:
      return Icons.dashboard_rounded;
    case AssetShellTab.inventory:
      return Icons.inventory_2_rounded;
    case AssetShellTab.myAssets:
      return Icons.devices_other_rounded;
    case AssetShellTab.scan:
      return Icons.qr_code_scanner_rounded;
    case AssetShellTab.search:
      return Icons.search_rounded;
    case AssetShellTab.calendar:
      return Icons.calendar_month_rounded;
    case AssetShellTab.pendingRequests:
      return Icons.pending_actions_rounded;
    case AssetShellTab.pendingReturns:
      return Icons.assignment_return_rounded;
    case AssetShellTab.pendingDamage:
      return Icons.build_circle_rounded;
    case AssetShellTab.guests:
      return Icons.person_outline_rounded;
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: selected
            ? Colors.white.withValues(alpha: 0.22)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 20, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight:
                          selected ? FontWeight.w800 : FontWeight.w600,
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Material(
        color: selected
            ? Colors.white.withValues(alpha: 0.22)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: Icon(icon, color: Colors.white),
          title: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              fontSize: 14,
            ),
          ),
          selected: selected,
          onTap: onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
