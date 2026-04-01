import 'package:flutter/material.dart';

enum NavSection { dashboard, sharedItems, cultureBoards, announcements }

extension NavSectionX on NavSection {
  String get label {
    switch (this) {
      case NavSection.dashboard:
        return 'Dashboard';
      case NavSection.sharedItems:
        return 'Shared Items';
      case NavSection.cultureBoards:
        return 'Culture Boards';
      case NavSection.announcements:
        return 'Announcements';
    }
  }

  IconData get icon {
    switch (this) {
      case NavSection.dashboard:
        return Icons.dashboard_customize_outlined;
      case NavSection.sharedItems:
        return Icons.folder_shared_outlined;
      case NavSection.cultureBoards:
        return Icons.grid_view_rounded;
      case NavSection.announcements:
        return Icons.campaign_outlined;
    }
  }
}

class ContentSidebar extends StatelessWidget {
  final NavSection active;
  final ValueChanged<NavSection> onChanged;
  final VoidCallback onBack;
  final bool isCultureBoardsView;

  const ContentSidebar({
    super.key,
    required this.active,
    required this.onChanged,
    required this.onBack,
    required this.isCultureBoardsView,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 256,
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 28),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Share',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Enterprise Workspace',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Back
          _BackRow(onTap: onBack),
          const SizedBox(height: 10),

          // ── Nav items ──────────────────────────────────────────────
          for (final section in NavSection.values)
            _NavItem(
              icon: section.icon,
              label: section.label,
              isActive: active == section,
              onTap: () => onChanged(section),
            ),
          const Spacer(),
        ],
      ),
    );
  }
}

// ── Nav Item ──────────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  static const _activeBg = Colors.white;
  static const _inactiveFg = Color(0xFF94A3B8);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? _activeBg : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isActive ? const Color(0xFF0F172A) : _inactiveFg,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
                  color: isActive ? const Color(0xFF0F172A) : _inactiveFg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Back row (top, culture boards view) ──────────────────────────────────────

class _BackRow extends StatelessWidget {
  final VoidCallback onTap;
  const _BackRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Row(
          children: const [
            Icon(Icons.arrow_back, size: 18, color: Color(0xFF94A3B8)),
            SizedBox(width: 10),
            Text(
              'Back',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}