import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Required for BlocBuilder
import 'package:my_app/event_management/features/notification/presentation/screen/notification_screen.dart';
import 'package:my_app/event_management/features/notification/presentation/bloc/notification_bloc.dart';

class ModernDashboardHeader extends StatelessWidget {
  final String adminName;

  const ModernDashboardHeader({
    super.key,
    required this.adminName,
  });

  // Your requested brand purple color #7F3DFF
  static const Color brandPurple = Color(0xFF7F3DFF);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textGrey = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Side: Greeting and Workflow Text
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome back, $adminName",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Manage the workflow being more productive",
                  style: TextStyle(
                    fontSize: 14,
                    color: textGrey,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // Right Side: Dynamic Purple Notification Bell
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              // We use the unreadCount getter from your NotificationState
              final count = state.unreadCount;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationScreen(),
                    ),
                  );
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // The Purple Icon Button Container
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: brandPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        size: 26,
                        color: brandPurple,
                      ),
                    ),

                    // Dynamic Counter Badge (Disappears if count is 0)
                    if (count > 0)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          decoration: BoxDecoration(
                            color: brandPurple,
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
              );
            },
          ),
        ],
      ),
    );
  }
}