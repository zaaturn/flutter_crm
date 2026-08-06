import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/employee_dashboard/bloc/employee_dashboard_bloc.dart';
import 'package:my_app/employee_dashboard/bloc/employee_dashboard_state.dart';
import 'package:my_app/event_management/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:my_app/event_management/features/notification/presentation/screen/mobile/notification_screen_mobile.dart';
import 'package:my_app/core/auth/auth_session_redirect.dart';
import 'package:my_app/auth/mobile_workspace_switch_sheet.dart';
import 'package:my_app/auth/profile_remote_sync.dart';
import 'package:my_app/employee_dashboard/widget/device_specific/v2/employee_workspace_access.dart';

class TopBar extends StatefulWidget {
  final BuildContext scaffoldContext;

  const TopBar({
    super.key,
    required this.scaffoldContext,
  });

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  bool _canOpenAdminWorkspace = false;
  static const Color pastelBlue = Color(0xFFC1DBE8);
  static const Color darkSlate = Color(0xFF0F172A);

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
    final canSwitch = await employeeCanSwitchWorkspace();
    if (!mounted) return;
    setState(() => _canOpenAdminWorkspace = canSwitch);
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text("Logout", style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
          content: Text("Are you sure you want to logout from Zaaturn?", style: GoogleFonts.manrope()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text("Cancel", style: GoogleFonts.manrope(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);
                await AuthSessionRedirect.logoutAndGoToLogin(context: context);
              },
              child: Text("Logout", style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: pastelBlue,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: darkSlate.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: BlocBuilder<EmployeeBloc, EmployeeState>(
        builder: (context, state) {
          final String displayName = state.employee?.displayName ?? 'User';

          return Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Welcome Back,",
                      style: GoogleFonts.manrope(
                        color: darkSlate.withValues(alpha: 0.60),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      displayName,
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: darkSlate,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (_canOpenAdminWorkspace)
                IconButton(
                  onPressed: () => MobileWorkspaceSwitchSheet.show(context),
                  icon: const Icon(Icons.sync_rounded, color: darkSlate, size: 22),
                ),
              BlocBuilder<NotificationBloc, NotificationState>(
                builder: (context, nState) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const NotificationScreenMobile()),
                        ),
                        icon: const Icon(Icons.notifications_none_rounded, color: darkSlate),
                      ),
                      if (nState.unreadCount > 0)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                            decoration: const BoxDecoration(
                              color: Color(0xFFEF4444),
                              borderRadius: BorderRadius.all(Radius.circular(999)),
                            ),
                            child: Center(
                              child: Text(
                                nState.unreadCount > 99 ? '99+' : '${nState.unreadCount}',
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
                },
              ),
              IconButton(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Icons.power_settings_new_rounded, color: Color(0xFFE11D48)),
              ),
            ],
          );
        },
      ),
    );
  }
}