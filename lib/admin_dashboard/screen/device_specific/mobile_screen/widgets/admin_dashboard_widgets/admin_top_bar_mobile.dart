import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/core/auth/auth_session_redirect.dart';
import 'package:my_app/auth/mobile_workspace_switch_sheet.dart';
import 'package:my_app/event_management/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:my_app/event_management/features/notification/presentation/screen/mobile/notification_screen_mobile.dart';

abstract final class AdminMobileTerracottaTheme {
  static const terracotta = Color(0xFFC05C39);
  static const terracottaDark = Color(0xFFA84A2E);
  static const cream = Color(0xFFFAF9F6);
  static const creamMuted = Color(0xFFF2EDE4);
  static const onTerracotta = Color(0xFFFAF9F6);
  static const onTerracottaMuted = Color(0xFFEADBC8);

  /// Admin workspace switch — darker lavender purple.
  static const adminSwitch = Color(0xFF9580D6);
  /// Bell notification chip — vibrant green.
  static const bellFill = Color(0xFF4CD137);
  /// Logout action fill.
  static const logoutFill = Color(0xFFE11D48);
}

class AdminTopBarMobile extends StatelessWidget {
  const AdminTopBarMobile({super.key});

  static Future<void> _openNotifications(BuildContext context) async {
    try {
      final bloc = context.read<NotificationBloc>();
      bloc.add(NotificationLoadRequested());
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => BlocProvider.value(
            value: bloc,
            child: const NotificationScreenMobile(),
          ),
        ),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notifications unavailable')),
      );
    }
  }

  static Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Sign Out',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Are you sure you want to leave?',
          style: GoogleFonts.manrope(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminMobileTerracottaTheme.logoutFill,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    if (!context.mounted) return;
    await AuthSessionRedirect.logoutAndGoToLogin(context: context);
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, topInset + 8, 16, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AdminMobileTerracottaTheme.terracotta.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AdminMobileTerracottaTheme.terracotta.withValues(alpha: 0.35),
              ),
            ),
            child: Image.asset(
              'assets/images/logo.png',
              height: 24,
              width: 24,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Daxarrow',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AdminMobileTerracottaTheme.terracotta,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => MobileWorkspaceSwitchSheet.show(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AdminMobileTerracottaTheme.adminSwitch,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.sync_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Admin',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (ctx, nState) => _CircleAction(
              icon: Icons.notifications_none_rounded,
              onTap: () => _openNotifications(context),
              badgeCount: nState.unreadCount,
              backgroundColor: AdminMobileTerracottaTheme.bellFill,
              iconColor: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          _CircleAction(
            icon: Icons.power_settings_new_rounded,
            onTap: () => _handleLogout(context),
            backgroundColor: AdminMobileTerracottaTheme.logoutFill,
            iconColor: Colors.white,
          ),
        ],
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.onTap,
    this.badgeCount = 0,
    this.backgroundColor,
    this.iconColor,
    this.noFill = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final int badgeCount;
  final Color? backgroundColor;
  final Color? iconColor;
  final bool noFill;

  @override
  Widget build(BuildContext context) {
    final bg = noFill
        ? Colors.transparent
        : (backgroundColor ??
            AdminMobileTerracottaTheme.terracotta.withValues(alpha: 0.1));
    final fg = iconColor ?? AdminMobileTerracottaTheme.terracotta;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
              border: !noFill && backgroundColor == null
                  ? Border.all(
                      color: AdminMobileTerracottaTheme.terracotta
                          .withValues(alpha: 0.35),
                    )
                  : null,
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 22,
              color: fg,
            ),
          ),
        ),
        if (badgeCount > 0)
          Positioned(
            top: -6,
            right: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              decoration: BoxDecoration(
                color: AdminMobileTerracottaTheme.logoutFill,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: AdminMobileTerracottaTheme.cream,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  badgeCount > 99 ? '99+' : '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
