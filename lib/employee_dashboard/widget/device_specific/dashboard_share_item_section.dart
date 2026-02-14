import 'package:flutter/material.dart';
import 'package:my_app/employee_dashboard/model/shared_item_model.dart';

class DashboardSharedItemsSection extends StatelessWidget {
  final List<SharedItemModel> items;

  const DashboardSharedItemsSection({super.key, required this.items});

  // SaaS Design Palette
  static const Color _primaryBlue = Color(0xFF137FEC);
  static const Color _textMain = Color(0xFF1E293B);
  static const Color _textMuted = Color(0xFF94A3B8);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heading Section
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            "Shared Items", // Changed heading as requested
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _textMain,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Single Glass Container for all items
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.65),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: items.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                thickness: 1,
                color: Colors.black.withOpacity(0.05),
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (context, index) => _buildSharedItemRow(items[index]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSharedItemRow(SharedItemModel item) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Center aligned like activity rows
        children: [
          // Icon Circle
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.description_outlined,
              color: _primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),

          // Item Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _textMain,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Shared by ${item.sharedBy}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: _textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Trailing Arrow (Optional, common in this UI style)
          Icon(
            Icons.chevron_right_rounded,
            color: _textMuted.withOpacity(0.5),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.all(40),
      child: Center(
        child: Text(
          "No shared items available",
          style: TextStyle(color: _textMuted, fontSize: 14),
        ),
      ),
    );
  }
}