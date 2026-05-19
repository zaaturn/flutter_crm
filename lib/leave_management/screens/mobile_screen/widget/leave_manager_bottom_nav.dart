import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum LeaveManagerNavTab { dashboard, pending, approved, rejected }

class LeaveManagerBottomNav extends StatelessWidget {
  const LeaveManagerBottomNav({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final LeaveManagerNavTab selected;
  final ValueChanged<LeaveManagerNavTab> onSelect;

  @override
  Widget build(BuildContext context) {
    // Match AdminDashboard mobile bottom nav styling.
    const Color pastelBlue = Color(0xFFC1DBE8);
    const Color activeColor = Color(0xFF0F172A);
    const Color inactiveColor = Color(0xFF64748B);

    final items = [
      (
        icon: Icons.dashboard_rounded,
        label: 'DASH',
        tab: LeaveManagerNavTab.dashboard,
      ),
      (
        icon: Icons.pending_actions_outlined,
        label: 'PENDING',
        tab: LeaveManagerNavTab.pending,
      ),
      (
        icon: Icons.check_circle_outline,
        label: 'APPROVED',
        tab: LeaveManagerNavTab.approved,
      ),
      (
        icon: Icons.cancel_outlined,
        label: 'REJECTED',
        tab: LeaveManagerNavTab.rejected,
      ),
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
              final bool isSelected = selected == item.tab;

              return InkWell(
                onTap: () => onSelect(item.tab),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.40)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        size: 24,
                        color: isSelected ? activeColor : inactiveColor,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.w900 : FontWeight.w700,
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
