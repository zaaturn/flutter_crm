import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:my_app/event_management/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:my_app/event_management/features/notification/presentation/screen/desktop/notification_screen_desktop.dart';

import '../../shared/dashboard_ui_theme.dart';
import '../bloc/dashboard_bloc.dart';

/// Top bar: dynamic greeting left, month pill centered, actions right.
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardTopBar(
      onNotifications: () => _openNotifications(context),
      showMissedBadge: context.watch<DashboardBloc>().state.missedEvents.isNotEmpty,
    );
  }

  void _openNotifications(BuildContext context) {
    try {
      final bloc = context.read<NotificationBloc>();
      bloc.add(NotificationLoadRequested());
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => BlocProvider.value(
            value: bloc,
            child: const NotificationScreenDesktop(),
          ),
        ),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notifications unavailable')),
      );
    }
  }
}

class DashboardTopBar extends StatelessWidget {
  const DashboardTopBar({
    super.key,
    this.leading,
    required this.onNotifications,
    this.showMissedBadge = false,
    this.notificationBadge = false,
  });

  final Widget? leading;
  final VoidCallback onNotifications;
  final bool showMissedBadge;
  final bool notificationBadge;

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('EEEE, MMMM d').format(DateTime.now());

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: SizedBox(
        height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child: const DashboardMonthPill(),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (leading != null) leading!,
                Expanded(
                  child: Text(
                    DashboardUiTheme.greeting(),
                    style: TextStyle(
                      fontSize: leading != null ? 17 : 22,
                      fontWeight: FontWeight.w800,
                      color: DashboardUiTheme.textDark,
                      letterSpacing: -0.4,
                      height: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _HeaderIconButton(
                  icon: Icons.notifications_none_rounded,
                  tooltip: 'Notifications',
                  onPressed: onNotifications,
                  badge: notificationBadge || showMissedBadge,
                ),
                const SizedBox(width: 8),
                _HeaderIconButton(
                  icon: Icons.help_outline_rounded,
                  tooltip: 'Help',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Today is $dateLabel.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardMonthPill extends StatelessWidget {
  const DashboardMonthPill({super.key});

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat('MMMM yyyy').format(DateTime.now());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: DashboardUiTheme.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DashboardUiTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        monthLabel,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: DashboardUiTheme.textDark,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.badge = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DashboardUiTheme.cardBackground,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: DashboardUiTheme.border),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, size: 22, color: DashboardUiTheme.textDark),
              if (badge)
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: DashboardUiTheme.statEnded,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
