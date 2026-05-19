import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/auth/mobile_workspace_switch_sheet.dart';
import 'package:my_app/event_management/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:my_app/event_management/features/notification/presentation/screen/mobile/notification_screen_mobile.dart';
import 'package:my_app/screens/device_specific/welcome_mobile.dart';
import 'package:my_app/services/api_client.dart';

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
        title: Text('Sign Out', style: GoogleFonts.manrope(fontWeight: FontWeight.w800)),
        content: Text('Are you sure you want to leave?', style: GoogleFonts.manrope()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    await ApiClient().logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreenmobile()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color pastelBlue = Color(0xFFC1DBE8);
    const Color darkSlate = Color(0xFF0F172A);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: const BoxDecoration(
        color: pastelBlue,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: darkSlate.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
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
                color: darkSlate,
                letterSpacing: -0.5,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => MobileWorkspaceSwitchSheet.show(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: darkSlate.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.sync_rounded, size: 16, color: darkSlate),
                    const SizedBox(width: 6),
                    Text(
                      'Admin',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: darkSlate,
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
              ),
            ),
            const SizedBox(width: 8),
            _CircleAction(
              icon: Icons.power_settings_new_rounded,
              onTap: () => _handleLogout(context),
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final int badgeCount;
  final bool isDestructive;

  const _CircleAction({
    required this.icon,
    required this.onTap,
    this.badgeCount = 0,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    const Color darkSlate = Color(0xFF0F172A);
    const Color rose = Color(0xFFE11D48);

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
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 22,
              color: isDestructive ? rose : darkSlate,
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
                color: rose,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFC1DBE8), width: 2),
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