import 'package:flutter/material.dart';

class ModernDashboardHeader extends StatelessWidget {
  final String adminName;
  final Function(String)? onSearchChanged;

  const ModernDashboardHeader({
    super.key,
    required this.adminName,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          /// Greeting (flexible)
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome back",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getFormattedDate(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 20),

          /// Search (responsive)
          Expanded(
            flex: 4,
            child: Container(
              height: 44,
              constraints: const BoxConstraints(maxWidth: 500),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  hintText: "Search anything...",
                  hintStyle: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                  prefixIcon:
                  const Icon(Icons.search, size: 20, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          const SizedBox(width: 20),

          /// Only icons (no profile)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeaderIcon(Icons.notifications_none_rounded,
                  hasBadge: true),
              const SizedBox(width: 12),
              _buildHeaderIcon(Icons.chat_bubble_outline_rounded),
              const SizedBox(width: 12),
              _buildHeaderIcon(Icons.card_giftcard_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon, {bool hasBadge = false}) {
    return Stack(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF64748B)),
        ),
        if (hasBadge)
          Positioned(
            right: 10,
            top: 10,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFFFF8C32),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return "${now.day} ${months[now.month - 1]}, ${now.year}";
  }
}
