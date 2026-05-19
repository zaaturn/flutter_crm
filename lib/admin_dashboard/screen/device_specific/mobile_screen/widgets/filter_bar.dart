import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'filter_enum.dart';

class FilterBar extends StatelessWidget {
  final EmployeeFilter selected;
  final Map<EmployeeFilter, int> counts;
  final ValueChanged<EmployeeFilter> onSelect;

  const FilterBar({
    super.key,
    required this.selected,
    required this.counts,
    required this.onSelect,
  });

  static const _labels = {
    EmployeeFilter.all: 'All',
    EmployeeFilter.working: 'Working',
    EmployeeFilter.onBreak: 'Break',
    EmployeeFilter.absent: 'Log Out',
  };

  // Helper to get specific colors per filter
  Color _getBoxColor(EmployeeFilter f) {
    return switch (f) {
      EmployeeFilter.all => const Color(0xFF0F172A),     // Navy/Black
      EmployeeFilter.working => const Color(0xFF1D5603), // Deep Green
      EmployeeFilter.onBreak => const Color(0xFFC3F380), // Light Lime
      EmployeeFilter.absent => const Color(0xFFD13F13),  // Terracotta/Orange
    };
  }

  Color _getTextColor(EmployeeFilter f, bool active) {
    if (!active) return const Color(0xFF64748B);

    if (f == EmployeeFilter.onBreak) return const Color(0xFF7523B4);
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    const Color lightCream = Color(0xFFFAF9F6);

    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: lightCream,
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: EmployeeFilter.values.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final f = EmployeeFilter.values[index];
          final active = f == selected;
          final boxColor = _getBoxColor(f);
          final textColor = _getTextColor(f, active);

          return GestureDetector(
            onTap: () => onSelect(f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: active ? boxColor : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: active ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _labels[f]!,
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: active
                          ? textColor.withOpacity(0.15)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${counts[f] ?? 0}',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}