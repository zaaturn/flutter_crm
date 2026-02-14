import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final BuildContext scaffoldContext;

  const TopBar({
    super.key,
    required this.scaffoldContext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Drawer button
          GestureDetector(
            onTap: () {
              Scaffold.of(scaffoldContext).openDrawer();
            },
            child: _iconContainer(
              const Icon(Icons.menu, size: 22, color: Colors.black87),
            ),
          ),

          Row(
            children: [
              // Notification icon (with badge)
              GestureDetector(
                onTap: () {

                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _iconContainer(
                      const Icon(
                        Icons.notifications_none,
                        color: Colors.black54,
                      ),
                    ),

                    // 🔴 Badge (show only when count > 0)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        child: const Text(
                          "3", // replace with dynamic count later
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Profile icon
              _iconContainer(
                const Icon(Icons.person, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= ICON CONTAINER =================
  Widget _iconContainer(Widget child) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
          ),
        ],
      ),
      child: child,
    );
  }
}



