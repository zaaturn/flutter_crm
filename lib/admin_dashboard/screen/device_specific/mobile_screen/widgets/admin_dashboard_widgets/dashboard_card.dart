import 'package:flutter/material.dart';
import 'dashboard_item.dart';

class DashboardCard extends StatelessWidget {
  final DashboardItem item;

  const DashboardCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: item.bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, color: item.iconColor),
            ),
            const SizedBox(height: 14),
            Text(item.label),
          ],
        ),
      ),
    );
  }
}