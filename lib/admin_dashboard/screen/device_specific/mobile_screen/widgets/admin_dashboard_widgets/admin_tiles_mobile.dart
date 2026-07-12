import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminTilesMobile extends StatelessWidget {
  const AdminTilesMobile({
    super.key,
    required this.onEmployees,
    required this.onProjectsTasks,
    required this.onClients,
    required this.onBilling,
    required this.onAssets,
    required this.onLeave,
  });

  final VoidCallback onEmployees;
  final VoidCallback onProjectsTasks;
  final VoidCallback onClients;
  final VoidCallback onBilling;
  final VoidCallback onAssets;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SquareTile(
                selected: true,
                icon: Icons.grid_view_rounded,
                label: 'Dashboard',
                onTap: () {},
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _SquareTile(
                selected: false,
                icon: Icons.group_outlined,
                label: 'Employees',
                onTap: onEmployees,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _WideTile(
          icon: Icons.assignment_outlined,
          label: 'Projects & Tasks',
          onTap: onProjectsTasks,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _SquareTile(
                selected: false,
                icon: Icons.handshake_outlined,
                label: 'Clients',
                onTap: onClients,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _SquareTile(
                selected: false,
                icon: Icons.payments_outlined,
                label: 'Billing',
                onTap: onBilling,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _SquareTile(
                selected: false,
                icon: Icons.inventory_2_outlined,
                label: 'Assets',
                onTap: onAssets,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _SquareTile(
                selected: false,
                icon: Icons.event_busy_outlined,
                label: 'Leave Mgmt',
                onTap: onLeave,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SquareTile extends StatelessWidget {
  const _SquareTile({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFFE8F0FF) : const Color(0xFFF1F5F9);
    final border = selected ? const Color(0xFFCBD5E1) : const Color(0xFFE2E8F0);
    final iconBg = selected ? const Color(0xFF2563EB) : Colors.white;
    final iconFg = selected ? Colors.white : const Color(0xFF111827);
    final textFg = selected ? const Color(0xFF1D4ED8) : const Color(0xFF0F172A);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        height: 132,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                          blurRadius: 14,
                          offset: const Offset(0, 8),
                        )
                      ]
                    : null,
              ),
              child: Icon(icon, color: iconFg),
            ),
            const Spacer(),
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: textFg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WideTile extends StatelessWidget {
  const _WideTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        height: 74,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFF111827)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}

