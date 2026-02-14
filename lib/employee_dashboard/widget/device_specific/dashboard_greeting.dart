import 'package:flutter/material.dart';

class DashboardGreeting extends StatelessWidget {
  const DashboardGreeting({super.key});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;

    String greeting;
    IconData icon;

    if (hour < 12) {
      greeting = "Good Morning";
      icon = Icons.wb_sunny_rounded;
    } else if (hour < 17) {
      greeting = "Good Afternoon";
      icon = Icons.wb_sunny_outlined;
    } else {
      greeting = "Good Evening";
      icon = Icons.nights_stay_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 36,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Here’s your work overview for today",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
