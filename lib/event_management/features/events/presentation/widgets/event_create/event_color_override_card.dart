import 'package:flutter/material.dart';
import 'package:my_app/event_management/shared/themes/app_theme.dart';

import 'event_composer_white_card.dart';

/// Optional calendar color presets (edit flow); styled like other composer cards.
class EventColorOverrideCard extends StatelessWidget {
  final String colorOverrideHex;
  final ValueChanged<String> onSelected;
  final VoidCallback onReset;

  const EventColorOverrideCard({
    super.key,
    required this.colorOverrideHex,
    required this.onSelected,
    required this.onReset,
  });

  static const _presets = [
    '#E24B4A',
    '#378ADD',
    '#EF9F27',
    '#1D9E75',
    '#8B5CF6',
    '#EC4899',
    '#64748B',
  ];

  @override
  Widget build(BuildContext context) {
    return EventComposerWhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.palette_outlined,
                  color: AppTheme.textSecondary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Calendar color',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              if (colorOverrideHex.isNotEmpty)
                TextButton(
                  onPressed: onReset,
                  child: const Text('Reset'),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _presets.map((hex) {
              final color =
                  Color(int.parse('0xFF${hex.replaceAll('#', '')}'));
              final selected =
                  colorOverrideHex.toUpperCase() == hex.toUpperCase();
              return GestureDetector(
                onTap: () => onSelected(hex),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? AppTheme.textPrimary : AppTheme.borderLight,
                      width: selected ? 2.5 : 1,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
