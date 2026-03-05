import 'package:flutter/material.dart';

enum NavSection { sharedItems, cultureBoards, announcements }

extension NavSectionX on NavSection {
  String get label {
    switch (this) {
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
      case NavSection.sharedItems:
        return Icons.share_outlined;
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
      width: 220,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // ── Top section ────────────────────────────────────────────
          if (isCultureBoardsView)
            _BackRow(onTap: onBack)
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Text(
                'Culture Platform',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
            ),

          const SizedBox(height: 8),

          // ── Nav items ──────────────────────────────────────────────
          for (final section in NavSection.values)
            _NavItem(
              icon: section.icon,
              label: section.label,
              isActive: active == section,
              onTap: () => onChanged(section),
            ),

          // ── Bottom back button (sub-pages only) ────────────────────
          if (!isCultureBoardsView) ...[
            const Spacer(),
            _BottomBackButton(onTap: onBack),
          ],
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

  static const _cyan = Color(0xFF00BCD4);
  static const _cyanBg = Color(0xFFE0F7FA);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          // ── KEY FIX: solid cyan-tinted background when active ──
          color: isActive ? _cyanBg : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isActive
              ? Border(
            left: BorderSide(color: _cyan, width: 3),
          )
              : const Border(
            left: BorderSide(color: Colors.transparent, width: 3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? _cyan : const Color(0xFF6B7280),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? _cyan : const Color(0xFF6B7280),
              ),
            ),
          ],
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
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        child: Row(
          children: [
            const Icon(Icons.arrow_back,
                size: 16, color: Color(0xFF6B7280)),
            const SizedBox(width: 6),
            Text(
              'Back',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom back button (shared items / announcements) ─────────────────────────

class _BottomBackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BottomBackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.arrow_back,
                  size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'Back',
                style: TextStyle(
                    fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}