import 'package:flutter/material.dart';
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

  @override
  void didUpdateWidget(covariant BottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex &&
        _selectedIndex != widget.currentIndex) {
      _selectedIndex = widget.currentIndex;
    }
  }

  Future<void> _onItemTapped(int index) async {
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
        EmployeeDashboardNavigator.feed(context);
        break;
      case 3:
        EmployeeDashboardNavigator.leaveDashboard(context);
        break;
      case 4:
        await EmployeeDashboardNavigator.events(context);
        // Events is pushed on top of the current tab. When user comes back,
        // restore the tab highlight to whatever screen we're actually on.
        if (!mounted) return;
        setState(() {
          _selectedIndex = widget.currentIndex;
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color pastelBlue = Color(0xFFC1DBE8);
    const Color activeColor = Color(0xFF0F172A);
    const Color inactiveColor = Color(0xFF64748B);

    final items = const [
      _BottomNavItem(icon: Icons.dashboard_rounded, activeIcon: Icons.dashboard_rounded, label: 'HOME'),
      _BottomNavItem(icon: Icons.assignment_outlined, activeIcon: Icons.assignment_rounded, label: 'TASKS'),
      _BottomNavItem(icon: Icons.dynamic_feed_outlined, activeIcon: Icons.dynamic_feed_rounded, label: 'FEED'),
      _BottomNavItem(icon: Icons.event_busy_outlined, activeIcon: Icons.event_busy_rounded, label: 'LEAVE'),
      _BottomNavItem(icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month_rounded, label: 'EVENTS'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: pastelBlue,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: activeColor.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = _selectedIndex == index;
              return InkWell(
                onTap: () => _onItemTapped(index),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.4)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? item.activeIcon : item.icon,
                        size: 24,
                        color: isSelected ? activeColor : inactiveColor,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                          color: isSelected ? activeColor : inactiveColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}