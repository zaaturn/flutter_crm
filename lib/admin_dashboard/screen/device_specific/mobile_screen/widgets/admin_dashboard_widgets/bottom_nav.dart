import 'dart:ui';
import 'package:flutter/material.dart';
import 'nav_item.dart';

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
    const items = [
      NavItem(icon: Icons.home_rounded, label: 'HOME'),
      NavItem(icon: Icons.person_rounded, label: 'PROFILE'),
      NavItem(icon: Icons.chat_bubble_rounded, label: 'CHAT'),
      NavItem(icon: Icons.share_rounded, label: 'SHARE'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0C0F10).withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, -12),
            spreadRadius: -6,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(items.length, (index) {
                  final item = items[index];
                  final isSelected = selectedIndex == index;

                  return GestureDetector(
                    onTap: () => onTap(index),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          size: 24,
                          color: isSelected
                              ? const Color(0xFF4456BA)
                              : const Color(0xFF94A3B8),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected
                                ? const Color(0xFF4456BA)
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}