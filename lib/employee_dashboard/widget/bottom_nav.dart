import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withOpacity(0.98),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(children: [
        Expanded(child: _navItem(icon: Icons.grid_view, label: "Home")),
        Expanded(child: _navItem(icon: Icons.calendar_month, label: "Schedule")),
        Expanded(child: Center(child: Container(height: 56, width: 56, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black), child: const Icon(Icons.add, color: Colors.white, size: 28)))),
        Expanded(child: _navItem(icon: Icons.chat_bubble_outline, label: "Chat")),
        Expanded(child: _navItem(icon: Icons.person_outline, label: "Profile")),
      ]),
    );
  }

  Widget _navItem({required IconData icon, required String label}) {
    return Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 22, color: Colors.grey[700]), Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[700]))]);
  }
}
