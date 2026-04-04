import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

// Your existing logic imports
import 'package:my_app/auth/auth_navigation.dart';
import 'package:my_app/auth/profile_remote_sync.dart';
import 'package:my_app/employee_dashboard/bloc/employee_dashboard_bloc.dart';
import 'package:my_app/employee_dashboard/bloc/employee_dashboard_state.dart';
import 'package:my_app/employee_dashboard/navigation/employee_dashboard_navigation.dart';
import 'package:my_app/services/secure_storage_service.dart';

import 'dashboard_sidebar_content.dart';

/// DAXARROW SIDEBAR THEME CONSTANTS
class WorkspaceSidebarTheme {
  static const Color background = Colors.white;
  static const Color primaryPurple = Color(0xFF6F34DC);
  static const Color border = Color(0xFFE8E9F1);
  static const Color textMain = Color(0xFF1E1E24);
  static const Color textMuted = Color(0xFF64748B);
  static const Color activeBg = Color(0x0D6F34DC); // 5% opacity purple
}

class DashboardSidebar extends StatefulWidget {
  final VoidCallback? onNavigateLeave;
  final VoidCallback? onNavigateTask;
  final VoidCallback? onLogout;

  const DashboardSidebar({
    super.key,
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

  // REPLACED EMOJIS WITH MATERIAL ICONS
  static const _nav = <({String label, IconData icon})>[
    (label: 'Dashboard', icon: Icons.grid_view_rounded),
    (label: 'My Tasks', icon: Icons.assignment_outlined),
    (label: 'Activity Feed', icon: Icons.auto_awesome_mosaic_outlined),
    (label: 'Leave Request', icon: Icons.calendar_today_rounded),
    (label: 'Events', icon: Icons.event_note_rounded),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: WorkspaceSidebarTheme.background,
        border: Border(
          right: BorderSide(color: WorkspaceSidebarTheme.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Header Section
          DashboardSidebarContent.header(
            onOpenWorkspaceMenu: () => DashboardSidebarContent.showWorkspaceChooser(
              sidebarContext: context,
              canOpenAdminWorkspace: _canOpenAdminWorkspace,
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              children: [
                _SectionHeader(title: 'WORKSPACE'),
                for (var i = 0; i < 3; i++)
                  _NavTile(
                    label: _nav[i].label,
                    icon: _nav[i].icon,
                    isActive: _selected == i,
                    onTap: () => _onTap(i),
                  ),

                const SizedBox(height: 24),

                _SectionHeader(title: 'MANAGEMENT'),
                for (var i = 3; i < _nav.length; i++)
                  _NavTile(
                    label: _nav[i].label,
                    icon: _nav[i].icon,
                    isActive: _selected == i,
                    onTap: () => _onTap(i),
                  ),
              ],
            ),
          ),

          // Admin Workspace Button (Daxarrow Style)
          if (_canOpenAdminWorkspace)
            Padding(
              padding: const EdgeInsets.all(16),
              child: InkWell(
                onTap: () => AuthNavigation.openAdminShell(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: WorkspaceSidebarTheme.primaryPurple,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: WorkspaceSidebarTheme.primaryPurple.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Admin Panel',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 12),
                    ],
                  ),
                ),
              ),
            ),

          // User Section
          BlocBuilder<EmployeeBloc, EmployeeState>(
            builder: (ctx, state) {
              final emp = state.employee;
              final name = emp?.displayName ?? 'User';
              final initials = emp?.avatarInitials ?? 'U';
              return DashboardSidebarContent.userCard(
                name: name,
                initials: initials,
                onLogoutTap: () => widget.onLogout?.call(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 0, 12),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: WorkspaceSidebarTheme.textMuted,
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavTile({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? WorkspaceSidebarTheme.primaryPurple : WorkspaceSidebarTheme.textMuted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? WorkspaceSidebarTheme.activeBg : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 14),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? WorkspaceSidebarTheme.primaryPurple : WorkspaceSidebarTheme.textMain,
                ),
              ),
              if (isActive) ...[
                const Spacer(),
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: WorkspaceSidebarTheme.primaryPurple,
                    shape: BoxShape.circle,
                  ),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}