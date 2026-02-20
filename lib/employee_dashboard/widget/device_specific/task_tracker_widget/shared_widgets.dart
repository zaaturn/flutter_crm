import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────
/// View Toggle (Board/List)
/// ─────────────────────────────────────────────────────────
class ViewToggle extends StatelessWidget {
  const ViewToggle({
    super.key,
    required this.isBoardView,
    required this.onToggle,
  });

  final bool isBoardView;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleBtn(
            icon: Icons.grid_view_rounded,
            label: 'Board',
            isActive: isBoardView,
            onTap: () => onToggle(true),
          ),
          const SizedBox(width: 2),
          _ToggleBtn(
            icon: Icons.view_list_rounded,
            label: 'List',
            isActive: !isBoardView,
            onTap: () => onToggle(false),
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────
/// Toggle Button
/// ─────────────────────────────────────────────────────────
class _ToggleBtn extends StatelessWidget {
  const _ToggleBtn({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          boxShadow: isActive
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isActive
                  ? const Color(0xFF6366F1)
                  : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? const Color(0xFF0F172A)
                    : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────
/// Icon Button
/// ─────────────────────────────────────────────────────────
class IconBtn extends StatelessWidget {
  const IconBtn({
    super.key,
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 17,
            color: const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────
/// Header Cell (List table)
/// ─────────────────────────────────────────────────────────
class HeaderCell extends StatelessWidget {
  const HeaderCell(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.7,
        color: Color(0xFF94A3B8),
      ),
    );
  }
}