import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/admin_dashboard/shared/admin_dashboard_theme.dart';
import 'package:my_app/admin_dashboard/sidebar/device_specific/workspace_switcher_desktop.dart';
import 'package:my_app/employee_dashboard/bloc/employee_dashboard_bloc.dart';
import 'package:my_app/employee_dashboard/bloc/employee_dashboard_state.dart';
import 'package:my_app/employee_dashboard/widget/employee_avatar.dart';
import 'package:my_app/event_management/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:my_app/event_management/features/notification/presentation/screen/desktop/notification_screen_desktop.dart';

/// Top row — DAXARROW left, workspace / notifications / profile right.
class ModernDashboardHeader extends StatelessWidget {
  final String adminName;
  final BuildContext parentContext;
  final bool showWorkspaceSwitcher;
  final VoidCallback onProfileClick;

  const ModernDashboardHeader({
    super.key,
    required this.adminName,
    required this.parentContext,
    required this.onProfileClick,
    this.showWorkspaceSwitcher = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'DAXARROW',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
              color: AdminDashboardTheme.tealDark,
            ),
          ),
          const Spacer(),
          if (showWorkspaceSwitcher) ...[
            _ChangeoverButton(parentContext: parentContext),
            const SizedBox(width: 12),
          ],
          _NotificationBell(),
          const SizedBox(width: 12),
          _ProfileAvatar(
            fallbackName: adminName,
            onTap: onProfileClick,
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String fallbackName;
  final VoidCallback onTap;

  const _ProfileAvatar({
    required this.fallbackName,
    required this.onTap,
  });

  String _initials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'U';
    final words =
        trimmed.split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
    if (words.length >= 2) {
      return (words[0][0] + words[1][0]).toUpperCase();
    }
    if (trimmed.length >= 2) return trimmed.substring(0, 2).toUpperCase();
    return trimmed[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmployeeBloc, EmployeeState>(
      builder: (context, state) {
        final employee = state.employee;
        return Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: employee != null
                ? EmployeeAvatar.fromProfile(
                    employee,
                    size: 42,
                    border: Border.all(color: AdminDashboardTheme.border),
                  )
                : EmployeeAvatar(
                    initials: _initials(fallbackName),
                    size: 42,
                    backgroundColor: AdminDashboardTheme.tealLight,
                    foregroundColor: AdminDashboardTheme.tealDark,
                    border: Border.all(color: AdminDashboardTheme.border),
                  ),
          ),
        );
      },
    );
  }
}

class _NotificationBell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        final count = state.unreadCount;
        return Material(
          color: AdminDashboardTheme.iconRailBg,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationScreenDesktop(),
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
                    color: AdminDashboardTheme.textDark,
                  ),
                  if (count > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE05252),
                          shape: BoxShape.circle,
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

class _ChangeoverButton extends StatelessWidget {
  final BuildContext parentContext;

  const _ChangeoverButton({required this.parentContext});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Change workspace',
      child: Material(
        color: AdminDashboardTheme.accentYellow,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => WorkspaceSwitcherSheet.show(context, parentContext),
          child: const SizedBox(
            width: 42,
            height: 42,
            child: Icon(
              Icons.swap_horiz_rounded,
              size: 22,
              color: AdminDashboardTheme.textDark,
            ),
          ),
        ),
      ),
    );
  }
}
