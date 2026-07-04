import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'admin_top_bar_mobile.dart';

class BottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const BottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    final items = [
      _BottomNavItem(
        icon: Icons.grid_view_rounded,
        activeIcon: Icons.grid_view_rounded,
        label: 'DASH',
      ),
      _BottomNavItem(
        icon: Icons.people_outline_rounded,
        activeIcon: Icons.people_rounded,
        label: 'STAFF',
      ),
      _BottomNavItem(
        icon: Icons.chat_bubble_outline_rounded,
        activeIcon: Icons.chat_bubble_rounded,
        label: 'CHAT',
      ),
      _BottomNavItem(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: 'PROFILE',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AdminMobileTerracottaTheme.terracotta,
        boxShadow: [
          BoxShadow(
            color: AdminMobileTerracottaTheme.terracottaDark
                .withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(8, 6, 8, 6 + bottomInset),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isSelected = selectedIndex == index;

            return InkWell(
              onTap: () {
                if (index == 2) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Feature launching soon'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }
                onTap(index);
              },
              borderRadius: BorderRadius.circular(6),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AdminMobileTerracottaTheme.cream
                          .withValues(alpha: 0.95)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected ? item.activeIcon : item.icon,
                      size: 20,
                      color: isSelected
                          ? AdminMobileTerracottaTheme.terracotta
                          : AdminMobileTerracottaTheme.onTerracottaMuted,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.label,
                      style: GoogleFonts.manrope(
                        fontSize: 9,
                        fontWeight:
                            isSelected ? FontWeight.w900 : FontWeight.w700,
                        color: isSelected
                            ? AdminMobileTerracottaTheme.terracotta
                            : AdminMobileTerracottaTheme.onTerracottaMuted,
                        letterSpacing: 0.4,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
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
