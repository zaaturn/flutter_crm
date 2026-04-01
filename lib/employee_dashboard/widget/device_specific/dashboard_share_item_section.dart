import 'package:flutter/material.dart';
import 'package:my_app/employee_dashboard/model/shared_item_model.dart';

class DashboardSharedItemsSection extends StatelessWidget {
  final List<SharedItemModel> items;

  const DashboardSharedItemsSection({super.key, required this.items});

  // --- Professional Purple SaaS Palette ---
  static const Color _primaryPurple = Color(0xFF7C3AED);
  static const Color _accentPurple = Color(0xFFF5F3FF);
  static const Color _textMain = Color(0xFF1E1B4B);
  static const Color _textMuted = Color(0xFF6366F1);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heading Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: _primaryPurple,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Shared Items",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _textMain,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Single Glass Container
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _primaryPurple.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: _primaryPurple.withOpacity(0.06),
                blurRadius: 24,
                offset: const Offset(0, 8),
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
                color: _primaryPurple.withOpacity(0.05),
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
    return InkWell( // Added ripple for professional feel
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Icon Circle with Gradient or Solid Purple
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _accentPurple,
                borderRadius: BorderRadius.circular(14), // Squircle look
              ),
              child: const Icon(
                Icons.folder_shared_rounded, // Swapped for a more "Shared" vibe
                color: _primaryPurple,
                size: 22,
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
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _textMain,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        "Shared by ",
                        style: TextStyle(
                          fontSize: 12,
                          color: _textMuted.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        item.sharedBy,
                        style: const TextStyle(
                          fontSize: 12,
                          color: _primaryPurple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Trailing Arrow
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: _primaryPurple.withOpacity(0.3),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.auto_awesome_motion_rounded, color: _primaryPurple.withOpacity(0.2), size: 40),
            const SizedBox(height: 12),
            const Text(
              "No shared items yet",
              style: TextStyle(
                color: _textMuted,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}