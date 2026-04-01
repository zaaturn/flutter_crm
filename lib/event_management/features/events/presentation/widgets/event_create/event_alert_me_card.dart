import 'package:flutter/material.dart';
import 'package:my_app/event_management/shared/themes/app_theme.dart';

import 'event_composer_white_card.dart';

/// 2×2 reminder interval chips (multi-select).
class EventAlertMeCard extends StatelessWidget {
  final List<int> selected;
  final ValueChanged<List<int>> onChanged;

  const EventAlertMeCard({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const _options = [
    (label: '10m before', value: 10),
    (label: '30m before', value: 30),
    (label: '1h before', value: 60),
    (label: '1d before', value: 1440),
  ];

  @override
  Widget build(BuildContext context) {
    return EventComposerWhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.notifications_outlined,
                  color: AppTheme.textSecondary, size: 22),
              const SizedBox(width: 10),
              Text(
                'Alert Me',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.4,
            children: _options.map((opt) {
              final isSel = selected.contains(opt.value);
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    final next = List<int>.from(selected);
                    if (isSel) {
                      next.remove(opt.value);
                    } else {
                      next.add(opt.value);
                    }
                    onChanged(next);
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSel ? AppTheme.primaryBlue : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSel
                            ? AppTheme.primaryBlue
                            : AppTheme.borderLight,
                      ),
                    ),
                    child: Text(
                      opt.label,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color:
                            isSel ? Colors.white : AppTheme.textSecondary,
                      ),
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
