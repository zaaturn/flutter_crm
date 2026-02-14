import 'package:flutter/material.dart';

import 'package:my_app/event_management/core/constants/app_colors.dart';

import '../../domain/entities/event_entity.dart';


class EventChip extends StatelessWidget {
  final EventEntity event;
  final VoidCallback onTap;

  const EventChip({super.key, required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tc = EventTypeColor .of(event.eventType);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: tc.bg,
          borderRadius: BorderRadius.circular(4),
          border: Border(
            left: BorderSide(color: tc.text, width: 3),
          ),
        ),
        child: Text(
          '${_fmt(event.start)}  ${event.title}',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: tc.text,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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