import 'package:flutter/material.dart';

import 'package:my_app/admin_dashboard/shared/admin_dashboard_theme.dart';

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

/// Icon-only rail — mirrors the main dashboard's DesktopSidebar: a back
/// button up top, then the section icons grouped in a mint pill, each with
/// a hover tooltip in place of a text label.
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 16, 10, 16),
        child: Column(
          children: [
            _RailButton(
              icon: Icons.arrow_back_rounded,
              tooltip: 'Back to dashboard',
              selected: false,
              onTap: onBack,
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AdminDashboardTheme.iconRailBg,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  children: [
                    for (final section in NavSection.values)
                      _RailButton(
                        icon: section.icon,
                        tooltip: section.label,
                        selected: active == section,
                        onTap: () => onChanged(section),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RailButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool selected;
  final VoidCallback onTap;

  const _RailButton({
    required this.icon,
    required this.tooltip,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? AdminDashboardTheme.textDark
        : AdminDashboardTheme.iconInactive;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Tooltip(
        message: tooltip,
        waitDuration: const Duration(milliseconds: 400),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AdminDashboardTheme.accentYellow : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 22, color: color),
            ),
          ),
        ),
      ),
    );
  }
}
