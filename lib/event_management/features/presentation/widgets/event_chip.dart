import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/event_management/core/constants/app_colors.dart';
import '../../domain/entities/event_entity.dart';

class EventChip extends StatelessWidget {
  final EventEntity event;
  final VoidCallback onTap;

  const EventChip({super.key, required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tc = EventTypeColor.of(event.eventType);

    return ClipRRect( // Prevents any tiny overflow from showing outside the box
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: tc.text.withOpacity(0.15),
            border: Border.all(color: tc.text.withOpacity(0.3), width: 0.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 2.0,
                height: 16.0,
                decoration: BoxDecoration(
                  color: tc.text,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(width: 6),

              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: TextStyle(
                        fontSize: 11.0,
                        fontWeight: FontWeight.bold,
                        color: tc.text,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    Text(
                      _fmt(event.start),
                      style: TextStyle(
                        fontSize: 9.0,
                        color: tc.text.withOpacity(0.8),
                        height: 1.1, // Tighten line height
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _fmt(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }
}