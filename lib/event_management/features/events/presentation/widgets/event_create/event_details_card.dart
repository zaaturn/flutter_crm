import 'package:flutter/material.dart';
import 'package:my_app/event_management/shared/themes/app_theme.dart';

import 'event_composer_white_card.dart';

/// Multi-line description / notes field inside a card.
class EventDetailsCard extends StatelessWidget {
  final TextEditingController controller;

  const EventDetailsCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return EventComposerWhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.subject_rounded,
                  color: AppTheme.textSecondary, size: 22),
              const SizedBox(width: 10),
              Text(
                'Details',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: controller,
            minLines: 5,
            maxLines: 8,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Add a description or notes for this event…',
              hintStyle: TextStyle(
                color: AppTheme.textHint.withValues(alpha: 0.9),
              ),
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }
}
