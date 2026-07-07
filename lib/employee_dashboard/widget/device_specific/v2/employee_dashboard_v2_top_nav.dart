import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:my_app/admin_dashboard/shared/admin_dashboard_theme.dart';
import 'package:my_app/auth/profile_remote_sync.dart';
import 'package:my_app/employee_dashboard/widget/employee_avatar.dart';
import 'package:my_app/employee_dashboard/bloc/employee_dashboard_bloc.dart';
import 'package:my_app/employee_dashboard/bloc/employee_dashboard_state.dart';
import 'package:my_app/employee_dashboard/navigation/employee_dashboard_navigation.dart';
import 'package:my_app/event_management/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:my_app/event_management/features/notification/presentation/screen/desktop/notification_screen_desktop.dart';

import 'employee_dashboard_v2_theme.dart';
import 'employee_desktop_logout.dart';
import 'employee_workspace_access.dart';
import 'employee_workspace_switch_button.dart';

class EmployeeDashboardV2TopNav extends StatefulWidget {
  final VoidCallback onProfileClick;
  final bool showLogout;
  final int selectedIndex;

  const EmployeeDashboardV2TopNav({
    super.key,
    required this.onProfileClick,
    this.showLogout = true,
    this.selectedIndex = 0,
  });

  @override
  State<EmployeeDashboardV2TopNav> createState() =>
      _EmployeeDashboardV2TopNavState();
}

class _EmployeeDashboardV2TopNavState extends State<EmployeeDashboardV2TopNav> {
  late int _selected;
  bool _canSwitchWorkspace = false;

  static const _items = <({String label, IconData icon})>[
    (label: 'Dashboard', icon: Icons.grid_view_rounded),
    (label: 'My Tasks', icon: Icons.assignment_outlined),
    (label: 'Activity Feed', icon: Icons.auto_awesome_mosaic_outlined),
    (label: 'Leave Request', icon: Icons.calendar_today_outlined),
    (label: 'Events', icon: Icons.event_note_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedIndex;
    ProfileRemoteSync.authSessionEpoch.addListener(_onAuthEpoch);
    _loadRole();
  }

  @override
  void didUpdateWidget(covariant EmployeeDashboardV2TopNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _selected = widget.selectedIndex;
    }
  }

  @override
  void dispose() {
    ProfileRemoteSync.authSessionEpoch.removeListener(_onAuthEpoch);
    super.dispose();
  }

  void _onAuthEpoch() => _loadRole();

  Future<void> _loadRole() async {
    final canSwitch = await employeeCanSwitchWorkspace();
    if (!mounted) return;
    setState(() => _canSwitchWorkspace = canSwitch);
  }

  void _onNav(int index) {
    setState(() => _selected = index);
    switch (index) {
      case 0:
        EmployeeDashboardNavigator.dashboard(context);
      case 1:
        EmployeeDashboardNavigator.tasks(context);
      case 2:
        EmployeeDashboardNavigator.feed(context);
      case 3:
        EmployeeDashboardNavigator.leaveDashboard(context);
      case 4:
        EmployeeDashboardNavigator.events(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: EmployeeDashboardV2Theme.shell,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: EmployeeDashboardV2Theme.cardBorder),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: EmployeeDashboardV2Theme.maxContentWidth,
              ),
              child: SizedBox(
                height: EmployeeDashboardV2Theme.navHeight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    children: [
                      _brandMark(),
                      const SizedBox(width: 32),
                      Expanded(child: _navRow()),
                      _actions(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _brandMark() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Image.asset(
            EmployeeDashboardV2Theme.logoAsset,
            width: 38,
            height: 38,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 38,
              height: 38,
              color: EmployeeDashboardV2Theme.greenLight,
              child: const Icon(
                Icons.image_not_supported_outlined,
                color: EmployeeDashboardV2Theme.greenDark,
                size: 20,
              ),
            ),
          ),
        ),
        const SizedBox(width: 11),
        Text('DAXARROW', style: EmployeeDashboardV2Theme.wordmark()),
      ],
    );
  }

  Widget _navRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < _items.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            _navLink(i),
          ],
        ],
      ),
    );
  }

  Widget _navLink(int index) {
    final active = _selected == index;
    final item = _items[index];
    return TextButton(
      onPressed: () => _onNav(index),
      style: TextButton.styleFrom(
        foregroundColor: active
            ? AdminDashboardTheme.textDark
            : EmployeeDashboardV2Theme.textBody,
        backgroundColor:
            active ? EmployeeDashboardV2Theme.navYellow : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: active
              ? BorderSide(
                  color: EmployeeDashboardV2Theme.navYellow.withValues(
                    alpha: 0.9,
                  ),
                )
              : BorderSide.none,
        ),
      ),
      child: Text(
        item.label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: active ? FontWeight.w800 : FontWeight.w600,
          color: active
              ? AdminDashboardTheme.textDark
              : EmployeeDashboardV2Theme.textBody,
        ),
      ),
    );
  }

  Widget _actions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_canSwitchWorkspace) ...[
          EmployeeWorkspaceSwitchButton(parentContext: context),
          const SizedBox(width: 12),
        ],
        const _EmployeeNotificationBell(),
        if (widget.showLogout) ...[
          const SizedBox(width: 8),
          _LogoutButton(onPressed: _confirmLogout),
        ],
        const SizedBox(width: 8),
        BlocBuilder<EmployeeBloc, EmployeeState>(
          builder: (context, state) {
            final employee = state.employee;
            return InkWell(
              onTap: widget.onProfileClick,
              borderRadius: BorderRadius.circular(12),
              child: employee != null
                  ? EmployeeAvatar.fromProfile(
                      employee,
                      size: 40,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFCCEADB)),
                    )
                  : EmployeeAvatar(
                      initials: 'U',
                      size: 40,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFCCEADB)),
                    ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _confirmLogout() async {
    await confirmEmployeeDesktopLogout(context);
  }
}

class _EmployeeNotificationBell extends StatelessWidget {
  const _EmployeeNotificationBell();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        final unread = state.unreadCount;
        return Material(
          color: EmployeeDashboardV2Theme.surfaceAlt,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationScreenDesktop(),
                ),
              );
            },
            child: SizedBox(
              width: 42,
              height: 42,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.notifications_none_rounded,
                    size: 22,
                    color: EmployeeDashboardV2Theme.textDark,
                  ),
                  if (unread > 0)
                    Positioned(
                      right: 7,
                      top: 7,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: EmployeeDashboardV2Theme.green,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unread > 9 ? '9+' : '$unread',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Logout',
      child: Material(
        color: EmployeeDashboardV2Theme.surfaceAlt,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: const SizedBox(
            width: 42,
            height: 42,
            child: Icon(
              Icons.logout_rounded,
              size: 22,
              color: Color(0xFFE11D48),
            ),
          ),
        ),
      ),
    );
  }
}
