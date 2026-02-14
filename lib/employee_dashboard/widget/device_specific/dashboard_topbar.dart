import 'package:flutter/material.dart';

class DashboardTopBar extends StatelessWidget {
  const DashboardTopBar({super.key});

  // SaaS CRM Design Constants
  static const Color _slate900 = Color(0xFF1E293B);
  static const Color _slate500 = Color(0xFF94A3B8);
  static const Color _slate100 = Color(0xFFF1F5F9);
  static const Color _primaryBlue = Color(0xFF137FEC);
  static const Color _borderSlate = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    return Container(
      // Background white to separate from slate dashboard body
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Row(
        children: [
          // 1. WELCOME BACK TEXT
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Welcome Back,",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: _slate900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Check your progress today",
                  style: TextStyle(
                    fontSize: 13,
                    color: _slate500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // 2. SEARCH BAR (Center Focal Point)
          Expanded(
            flex: 4,
            child: _buildSearchBar(),
          ),

          const SizedBox(width: 40),

          // 3. ACTION ICONS & PROFILE
          Row(
            children: [
              // Notification remains as it's standard for dashboards
              const _TopBarIcon(icon: Icons.notifications_none_rounded, badge: 2),
              const SizedBox(width: 24),

              // NEW PROFILE UPLOAD/DISPLAY CIRCLE
              _buildProfileCircle(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: _slate100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderSlate.withOpacity(0.5)),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search anything...",
          hintStyle: const TextStyle(color: _slate500, fontSize: 13),
          prefixIcon: const Icon(Icons.search_rounded, color: _slate500, size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildProfileCircle() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          // Trigger Image Picker logic here
          print("Upload Profile Photo");
        },
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _primaryBlue, width: 2),
                image: const DecorationImage(
                  image: NetworkImage("https://ui-avatars.com/api/?name=User&background=137FEC&color=fff"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Tiny "Upload/Edit" Indicator
            Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: _primaryBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, size: 10, color: Colors.white),
            )
          ],
        ),
      ),
    );
  }
}

class _TopBarIcon extends StatelessWidget {
  final IconData icon;
  final int badge;

  const _TopBarIcon({required this.icon, this.badge = 0});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon, color: const Color(0xFF64748B), size: 24),
        if (badge > 0)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}