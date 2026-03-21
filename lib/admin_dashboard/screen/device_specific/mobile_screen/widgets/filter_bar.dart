import 'package:flutter/material.dart';
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
    EmployeeFilter.absent: 'Absent',
  };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.withAlpha(20),
              width: 1,
            ),
          ),
        ),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          itemCount: EmployeeFilter.values.length,
          separatorBuilder: (context, index) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final f = EmployeeFilter.values[index];
            final active = f == selected;

            return GestureDetector(
              onTap: () => onSelect(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: active ? const Color(0xFF0F172A) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: active ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                  boxShadow: active
                      ? [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withOpacity(0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                      : [],
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _labels[f]!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                          color: active ? Colors.white : const Color(0xFF64748B),
                          decoration: TextDecoration.none, // Double insurance against underlines
                        ),
                      ),
                      const SizedBox(width: 8),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: active
                              ? Colors.white.withOpacity(0.15)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${counts[f] ?? 0}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: active ? Colors.white : const Color(0xFF94A3B8),
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}