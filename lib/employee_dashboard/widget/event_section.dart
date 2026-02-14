import 'package:flutter/material.dart';
import '../model/event_model.dart';

class EventSection extends StatelessWidget {
  final List<EventModel> events;
  const EventSection({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Upcoming Events", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      Column(children: (events.isEmpty ? _mock() : events.map(_cardFromModel).toList()))
    ]);
  }

  Widget _cardFromModel(EventModel m) {
    // parse date for display
    final date = DateTime.tryParse(m.date);
    final month = date != null ? _month(date.month) : 'OCT';
    final day = date != null ? date.day.toString() : m.date;
    return _eventCard(month: month, date: day, title: m.title, time: m.time, location: m.location);
  }

  List<Widget> _mock() => [
    _eventCard(month: 'OCT', date: '25', title: 'Product Design Review', time: '10:00 AM', location: 'Room 302'),
    const SizedBox(height: 12),
    _eventCard(month: 'OCT', date: '28', title: 'Team Lunch', time: '1:00 PM', location: 'Cafeteria'),
  ];

  Widget _eventCard({required String month, required String date, required String title, required String time, required String location}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]),
      child: Row(children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)), child: Column(children: [Text(month, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(date, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))])),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)), const SizedBox(height: 8), Row(children: [const Icon(Icons.access_time, size: 14), const SizedBox(width: 6), Text(time), const SizedBox(width: 12), const Icon(Icons.location_on, size: 14), const SizedBox(width: 6), Text(location)])]))
      ]),
    );
  }

  String _month(int m) => ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"][m - 1];
}
