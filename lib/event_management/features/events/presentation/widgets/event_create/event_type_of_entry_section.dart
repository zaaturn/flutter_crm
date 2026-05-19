import 'package:flutter/material.dart';
import 'package:my_app/event_management/features/events/domain/entities/event.dart';
import 'package:my_app/event_management/shared/themes/app_theme.dart';

/// Horizontal chips for [EventType] selection.
class EventTypeOfEntrySection extends StatelessWidget {
  final EventType selected;
  final ValueChanged<EventType> onChanged;

  const EventTypeOfEntrySection({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TYPE OF ENTRY',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSecondary,
              ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: EventType.values.map((type) {
              final isSel = type == selected;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onChanged(type),
                    borderRadius: BorderRadius.circular(22),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSel ? const Color(0xFFEEF2FF) : Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isSel
                              ? AppTheme.primaryBlue.withValues(alpha: 0.35)
                              : AppTheme.borderLight,
                        ),
                      ),
                      child: Text(
                        type.label,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: isSel
                              ? AppTheme.primaryBlue
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
