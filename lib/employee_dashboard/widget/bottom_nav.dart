import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/employee_dashboard/navigation/employee_dashboard_navigation.dart';

class BottomNav extends StatefulWidget {
  final int currentIndex;

  const BottomNav({super.key, this.currentIndex = 0});

  @override
  State<BottomNav> createState() => _ModernBottomNavBarState();
}

class _ModernBottomNavBarState extends State<BottomNav> {
  late int _selectedIndex;

  static const _terracotta = Color(0xFFC05C39);
  static const _terracottaDark = Color(0xFFA84A2E);
  static const _ink = Color(0xFF1C1410);

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
        if (!mounted) return;
        setState(() {
          _selectedIndex = widget.currentIndex;
        });
        break;
      case 5:
        await EmployeeDashboardNavigator.assets(context);
        if (!mounted) return;
        setState(() {
          _selectedIndex = widget.currentIndex;
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = const [
      _BottomNavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: 'HOME',
      ),
      _BottomNavItem(
        icon: Icons.assignment_outlined,
        activeIcon: Icons.assignment_rounded,
        label: 'TASKS',
      ),
      _BottomNavItem(
        icon: Icons.dynamic_feed_outlined,
        activeIcon: Icons.dynamic_feed_rounded,
        label: 'FEED',
      ),
      _BottomNavItem(
        icon: Icons.event_busy_outlined,
        activeIcon: Icons.event_busy_rounded,
        label: 'LEAVE',
      ),
      _BottomNavItem(
        icon: Icons.calendar_month_outlined,
        activeIcon: Icons.calendar_month_rounded,
        label: 'EVENTS',
      ),
      _BottomNavItem(
        icon: Icons.inventory_2_outlined,
        activeIcon: Icons.inventory_2_rounded,
        label: 'ASSETS',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: _terracotta,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: _terracottaDark.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = _selectedIndex == index;
              return InkWell(
                onTap: () => _onItemTapped(index),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.92)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? item.activeIcon : item.icon,
                        size: 22,
                        color: isSelected
                            ? _ink
                            : _ink.withValues(alpha: 0.72),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected
                              ? _ink
                              : _ink.withValues(alpha: 0.72),
                          letterSpacing: 0.4,
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
