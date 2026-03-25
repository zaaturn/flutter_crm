import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Recommended for cleaner time formatting


 import 'package:my_app/event_management/core/constants/app_colors.dart';
import '../../domain/entities/event_entity.dart';

class EventChip extends StatelessWidget {
  final dynamic event; // Replace with EventEntity
  final VoidCallback onTap;

  const EventChip({super.key, required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Assuming tc has bg and text properties
    final tc = EventTypeColor.of(event.eventType);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            // Subtly border the card for a "clean" SaaS look
            border: Border.all(color: const Color(0xFFEDF2F7), width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x05000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // 1. The Accent Bar (The "Brand" color of the event)
              Container(
                width: 4,
                height: 32,
                decoration: BoxDecoration(
                  color: tc.text, // Using the prominent color for the bar
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),

              // 2. Event Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A202C),
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _fmt(event.start),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Trailing indicator (Optional: shows it's clickable)
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: Colors.grey[300],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Improved time formatter
  static String _fmt(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }
}