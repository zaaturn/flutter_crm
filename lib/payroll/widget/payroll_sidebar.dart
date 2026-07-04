import 'package:flutter/material.dart';

import 'package:my_app/admin_dashboard/shared/admin_dashboard_theme.dart';

/// Icon-only rail — mirrors the main dashboard's DesktopSidebar. Payroll is
/// currently a single-page module, so the one icon just marks "you are here"
/// (no page switching); a hover tooltip still names it.
class PayrollSidebar extends StatelessWidget {
  const PayrollSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 16, 10, 16),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AdminDashboardTheme.tealLight,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.payments_rounded,
                color: AdminDashboardTheme.teal,
                size: 22,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AdminDashboardTheme.iconRailBg,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: _RailButton(
                    icon: Icons.payments_outlined,
                    tooltip: 'Payroll Records',
                    selected: true,
                  ),
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

  const _RailButton({
    required this.icon,
    required this.tooltip,
    required this.selected,
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
        child: Container(
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
    );
  }
}
