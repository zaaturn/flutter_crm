import 'package:flutter/material.dart';
import '../model/shared_item_model.dart';

class SharedItemsSection extends StatelessWidget {
  final List<SharedItemModel> items;
  const SharedItemsSection({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
        Text("Shared Items", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        Text("View All", style: TextStyle(color: Colors.blue))
      ]),
      const SizedBox(height: 12),
      Column(children: (items.isEmpty ? _mock() : items.map(_cardFromModel).toList())),
    ]);
  }

  Widget _cardFromModel(SharedItemModel m) {
    return _sharedCard(iconColor: Colors.blue, title: m.title, desc: m.description, sharedBy: m.sharedBy, timeAgo: "${DateTime.now().difference(m.sharedAt).inHours}h ago");
  }

  List<Widget> _mock() => [
    _sharedCard(iconColor: const Color(0xFF3D6AFE), title: 'Company Policy Update', desc: 'New remote work guidelines...', sharedBy: 'Admin', timeAgo: '2h ago'),
    const SizedBox(height: 12),
    _sharedCard(iconColor: const Color(0xFF9B51E0), title: 'Town Hall Recording', desc: 'Missed the meeting? Watch the Q4 goals...', sharedBy: 'HR', timeAgo: 'Yesterday'),
    const SizedBox(height: 12),
    _sharedCard(iconColor: const Color(0xFF1ABC9C), title: 'Design Resources', desc: 'A collection of new UI kits and icons...', sharedBy: 'Design Lead', timeAgo: '3d ago'),
  ];

  Widget _sharedCard({required Color iconColor, required String title, required String desc, required String sharedBy, required String timeAgo}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: iconColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.insert_drive_file, color: iconColor)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)), const SizedBox(height: 6), Text(desc, style: TextStyle(color: Colors.grey[700]))])),
          const SizedBox(width: 8),
          const Icon(Icons.open_in_new, color: Colors.grey)
        ]),
        const SizedBox(height: 10),
        Text("Shared by $sharedBy • $timeAgo", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ]),
    );
  }
}
