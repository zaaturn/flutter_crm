import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_app/employee_dashboard/bloc/employee_dashboard_bloc.dart';
import 'package:my_app/employee_dashboard/bloc/employee_dashboard_state.dart';
import 'package:my_app/employee_dashboard/navigation/employee_dashboard_navigation.dart';
import 'package:my_app/auth/profile_remote_sync.dart';
import 'package:my_app/services/secure_storage_service.dart';

import 'dashboard_sidebar_content.dart';
import 'dashboard_sidebar_theme.dart';
import 'package:my_app/core/keyboard/keyboard_navigation.dart';

class DashboardSidebar extends StatefulWidget {
  final BuildContext? parentContext;
  final VoidCallback? onNavigateLeave;
  final VoidCallback? onNavigateTask;
  final VoidCallback? onLogout;

  const DashboardSidebar({
    super.key,
    this.parentContext,
    this.onNavigateLeave,
    this.onNavigateTask,
    this.onLogout,
  });

  @override
  State<DashboardSidebar> createState() => _DashboardSidebarState();
}

class _DashboardSidebarState extends State<DashboardSidebar> {
  int _selected = 0;
  bool _canOpenAdminWorkspace = false;

  static const _nav = <({String label, IconData icon})>[
    (label: 'Dashboard', icon: Icons.grid_view_rounded),
    (label: 'My Tasks', icon: Icons.assignment_outlined),
    (label: 'Activity Feed', icon: Icons.auto_awesome_mosaic_outlined),
    (label: 'Leave Request', icon: Icons.calendar_today_rounded),
    (label: 'Events', icon: Icons.event_note_rounded),
    (label: 'Assets', icon: Icons.inventory_2_outlined),
  ];

  @override
  void initState() {
    super.initState();
    ProfileRemoteSync.authSessionEpoch.addListener(_onAuthSessionEpoch);
    _loadRole();
  }

  @override
  void dispose() {
    ProfileRemoteSync.authSessionEpoch.removeListener(_onAuthSessionEpoch);
    super.dispose();
  }

  void _onAuthSessionEpoch() => _loadRole();

  Future<void> _loadRole() async {
    final r = await SecureStorageService().readRole();
    if (!mounted) return;
    setState(() => _canOpenAdminWorkspace = r?.toLowerCase() == 'admin');
  }

  void _onTap(int index) {
    setState(() => _selected = index);
    switch (index) {
      case 0:
        EmployeeDashboardNavigator.dashboard(context);
        break;
      case 1:
        widget.onNavigateTask?.call();
        EmployeeDashboardNavigator.tasks(context);
        break;
      case 2:
        EmployeeDashboardNavigator.feed(context);
        break;
      case 3:
        widget.onNavigateLeave?.call();
        EmployeeDashboardNavigator.leaveDashboard(context);
        break;
      case 4:
        EmployeeDashboardNavigator.events(context);
        break;
      case 5:
        EmployeeDashboardNavigator.assets(context);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardScope = dashboardSidebarKeyboardScopeOf(context);

    return Container(
      width: DashboardSidebarTheme.width,
      decoration: const BoxDecoration(
        color: DashboardSidebarTheme.background,
        border: Border(
          right: BorderSide(color: DashboardSidebarTheme.border, width: 1.5),
        ),
      ),
      child: Column(
        children: [
          _buildBrandHeader(),
          Expanded(
            child: KeyboardNavList(
              itemCount: _nav.length,
              selectedIndex: _selected,
              onSelectedIndexChanged: (index) => setState(() => _selected = index),
              onActivate: () => _onTap(_selected),
              autofocus: true,
              focusNode: keyboardScope?.focusNode,
              onMoveToNextRegion: keyboardScope?.onMoveToContent,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                physics: const BouncingScrollPhysics(),
                children: [
                  for (var i = 0; i < _nav.length; i++)
                    _buildNavTile(
                      label: _nav[i].label,
                      icon: _nav[i].icon,
                      isActive: _selected == i,
                      onTap: () => _onTap(i),
                    ),
                ],
              ),
            ),
          ),
          BlocBuilder<EmployeeBloc, EmployeeState>(
            builder: (ctx, state) {
              final emp = state.employee;
              final name = emp?.displayName ?? 'User';
              final initials = emp?.avatarInitials ?? 'U';

              return DashboardSidebarContent.userFooter(
                context: ctx,
                parentContext: widget.parentContext ?? ctx,
                name: name,
                initials: initials,
                photoUrl: emp?.profilePhoto,
                canSwitchWorkspace: _canOpenAdminWorkspace,
                onLogoutTap: () => widget.onLogout?.call(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBrandHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
      child: Row(
        children: [
          Image.asset(
            'assets/images/logo.png',
            width: 38,
            height: 38,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: DashboardSidebarTheme.purple,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(width: 14),
          Text('DAXARROW', style: DashboardSidebarTheme.brandWordmark()),
        ],
      ),
    );
  }

  Widget _buildNavTile({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isActive ? DashboardSidebarTheme.purpleLight : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? DashboardSidebarTheme.purple : DashboardSidebarTheme.textMuted,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label, style: DashboardSidebarTheme.navItem(active: isActive)),
            ),
          ],
        ),
      ),
    );
  }
}
