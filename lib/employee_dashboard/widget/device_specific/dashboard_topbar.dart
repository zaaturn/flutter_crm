import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/employee_dashboard/bloc/employee_dashboard_bloc.dart';
import 'package:my_app/employee_dashboard/bloc/employee_dashboard_state.dart';
import 'package:my_app/event_management/features/notification/presentation/screen/notification_screen.dart';
import 'package:my_app/event_management/features/notification/presentation/bloc/notification_bloc.dart';

class DashboardTopBar extends StatelessWidget {
  final VoidCallback onProfileClick;

  const DashboardTopBar({
    super.key,
    required this.onProfileClick,
  });

  static const Color _bgWhite = Color(0xFFFFFFFF);
  static const Color _textMain = Color(0xFF0F172A);
  static const Color _textMuted = Color(0xFF475569);
  static const Color _purple = Color(0xFF7C3AED);
  static const Color _purpleLight = Color(0xFFF5F3FF);
  static const Color _borderLight = Color(0xFFEDE9FE);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: _bgWhite,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          BlocBuilder<EmployeeBloc, EmployeeState>(
            builder: (context, state) {
              final userName = state.employee?.username ?? 'User';
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Dashboard",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: _textMain,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Text(
                        "Welcome back,",
                        style: TextStyle(
                          fontSize: 13,
                          color: _textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        userName.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 13,
                          color: _purple,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),


          Row(
            children: [

              BlocBuilder<NotificationBloc, NotificationState>(
                builder: (context, state) {
                  return _SaaSIconButton(
                    icon: Icons.notifications_rounded,

                    count: state.unreadCount,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationScreen(),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(width: 16),

              _buildDynamicProfile(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicProfile() {
    return BlocBuilder<EmployeeBloc, EmployeeState>(
      builder: (context, state) {
        final name = state.employee?.username ?? 'User';
        final initials = name.length >= 2
            ? name.substring(0, 2).toUpperCase()
            : name.toUpperCase();

        return InkWell(
          onTap: onProfileClick,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _purpleLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _borderLight),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _purple,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: _purple.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 8, right: 4),
                  child: Icon(Icons.expand_more_rounded, color: _purple, size: 20),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SaaSIconButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final VoidCallback onTap;

  const _SaaSIconButton({
    required this.icon,
    this.count = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F3FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEDE9FE)),
        ),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none, // Allows the badge to pop out slightly
          children: [
            const Icon(Icons.notifications_rounded, color: Color(0xFF7C3AED), size: 22),

            // Only show the badge if count > 0
            if (count > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444), // Red badge
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}