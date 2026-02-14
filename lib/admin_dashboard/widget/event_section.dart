import 'package:flutter/material.dart';
import '../model/events.dart';

class EventSection extends StatelessWidget {
  final List<DashboardEvent> events;

  const EventSection({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text(
              "Upcoming Events",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 6),
            Icon(Icons.event_note_outlined, size: 18),
          ],
        ),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: events.map((e) {
              return Column(
                children: [
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      e.title,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Text(
                      "${e.start.hour.toString().padLeft(2, '0')}:"
                          "${e.start.minute.toString().padLeft(2, '0')}",
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),

                  ),
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

