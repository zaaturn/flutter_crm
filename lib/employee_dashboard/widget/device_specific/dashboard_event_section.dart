import 'package:flutter/material.dart';
import 'package:my_app/employee_dashboard/model/event_model.dart';

class DashboardEventsSection extends StatelessWidget {
  final List<EventModel> events;

  const DashboardEventsSection({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: _sectionDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          const SizedBox(height: 20),
          events.isEmpty
              ? _empty()
              : LayoutBuilder(
            builder: (context, c) {
              final cols =
              c.maxWidth >= 1000 ? 3 : c.maxWidth >= 650 ? 2 : 1;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: events.length,
                gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 3,
                ),
                itemBuilder: (_, i) => _eventCard(events[i]),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _eventCard(EventModel e) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _itemDecoration(),
      child: Row(
        children: [
          const Icon(Icons.event_rounded, color: Color(0xFF8B5CF6)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text("${e.date} • ${e.location}",
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF64748B))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() => Row(
    children: const [
      Icon(Icons.event_rounded, color: Color(0xFF8B5CF6)),
      SizedBox(width: 12),
      Text("Upcoming Events",
          style:
          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    ],
  );

  Widget _empty() => Padding(
    padding: const EdgeInsets.all(32),
    child: Center(
      child: Text("No upcoming events",
          style:
          TextStyle(fontSize: 15, color: Color(0xFF64748B))),
    ),
  );

  BoxDecoration _sectionDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: const Color(0xFFE2E8F0)),
  );

  BoxDecoration _itemDecoration() => BoxDecoration(
    color: const Color(0xFFF8FAFC),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: const Color(0xFFE2E8F0)),
  );
}
