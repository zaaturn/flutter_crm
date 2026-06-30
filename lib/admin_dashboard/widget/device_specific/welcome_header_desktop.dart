import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/admin_dashboard/shared/admin_dashboard_theme.dart';
import 'package:my_app/admin_dashboard/sidebar/device_specific/workspace_switcher_desktop.dart';
import 'package:my_app/event_management/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:my_app/event_management/features/notification/presentation/screen/desktop/notification_screen_desktop.dart';

/// Top row — DAXARROW left, workspace / notifications / profile right.
class ModernDashboardHeader extends StatelessWidget {
  final String adminName;
  final BuildContext parentContext;
  final bool showWorkspaceSwitcher;

  const ModernDashboardHeader({
    super.key,
    required this.adminName,
    required this.parentContext,
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
          _ProfileChip(name: adminName),
        ],
      ),
    );
  }
}

class _ProfileChip extends StatelessWidget {
  final String name;

  const _ProfileChip({required this.name});

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () {},
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: AdminDashboardTheme.tealLight,
            child: Text(
              initial,
              style: const TextStyle(
                color: AdminDashboardTheme.tealDark,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AdminDashboardTheme.profileName(),
            ),
          ),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 20,
            color: AdminDashboardTheme.textMuted,
          ),
        ],
      ),
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
