import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:my_app/asset_management/navigation/asset_flow_controller.dart';
import 'package:my_app/asset_management/presentation/screens/asset_scan_screen.dart';
import 'package:my_app/employee_dashboard/navigation/employee_dashboard_navigation.dart';

/// Home shortcut so employees can open Assets without hunting in menus.
class EmployeeAssetsQuickActions extends StatelessWidget {
  const EmployeeAssetsQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    const terracotta = Color(0xFFC05C39);
    const cream = Color(0xFFFAF9F6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assets',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF2C241E),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _ActionTile(
                icon: Icons.inventory_2_outlined,
                label: 'My Assets',
                subtitle: 'Assigned to you',
                color: terracotta,
                background: cream,
                onTap: () => EmployeeDashboardNavigator.assets(context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionTile(
                icon: Icons.qr_code_scanner,
                label: 'Scan QR',
                subtitle: 'Request / return',
                color: const Color(0xFF1F5F52),
                background: const Color(0xFFE8F5F0),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const AssetScanScreen(useMobileTheme: true),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => AssetFlowController.openEmployee(context),
            child: Text(
              'Open assets module',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: terracotta,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.background,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 10),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: const Color(0xFF2C241E),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF8A7A6E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
