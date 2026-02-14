import 'package:flutter/material.dart';

import 'package:my_app/event_management/core/constants/app_colors.dart';

import 'mock_data.dart';

/// Grid of 4 tappable type cards – mirrors the React type-selector exactly.
class TypeSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const TypeSelector({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: EVENT_TYPES
          .map((type) => _TypeOption(
        type: type,
        isSelected: type == selected,
        onTap: () => onChanged(type),
      ))
          .toList(),
    );
  }
}

class _TypeOption extends StatelessWidget {
  final String type;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeOption({required this.type, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tc = EventTypeColor.of(type);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? tc.bg : const Color(0xFFFAFBFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? tc.border : AppColors.border,
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(EVENT_TYPE_ICONS[type] ?? '', style: const TextStyle(fontSize: 17)),
              const SizedBox(height: 3),
              Text(
                EVENT_TYPE_LABELS[type] ?? type,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? tc.text : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}