import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/design_tokens.dart';
import 'package:my_app/employee_dashboard/navigation/employee_dashboard_navigation.dart';
class BottomNav extends StatefulWidget {

  final int currentIndex;

  const BottomNav({super.key, this.currentIndex = 0});

  @override
  State<BottomNav> createState() => _ModernBottomNavBarState();
}

class _ModernBottomNavBarState extends State<BottomNav> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    // --- NAVIGATION LOGIC ---
    switch (index) {
      case 0:
        EmployeeDashboardNavigator.dashboard(context);
        break;
      case 1:
        EmployeeDashboardNavigator.tasks(context);
        break;
      case 2:
        EmployeeDashboardNavigator.leaveDashboard(context);
        break;
      case 3:
        EmployeeDashboardNavigator.events(context);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28.0)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            border: Border(
              top: BorderSide(color: Colors.grey.shade200, width: 0.5),
            ),
          ),
          padding:
          const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.dashboard_rounded, "Dashboard", 0),
              _buildNavItem(Icons.assignment_rounded, "My Tasks", 1),
              _buildNavItem(Icons.event_busy_rounded, "Leave", 2),
              _buildNavItem(Icons.calendar_month_rounded, "Events", 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: AppTextStyles.label(
                fontSize: 10,
                color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}