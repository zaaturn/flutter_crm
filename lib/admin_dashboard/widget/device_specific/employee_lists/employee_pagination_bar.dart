import 'package:flutter/material.dart';
import 'package:my_app/admin_dashboard/shared/admin_dashboard_theme.dart';

/// Prev/next pager for the desktop employee table — designed to stay cheap
/// to render at scale (1000+ employees / 100+ pages) by never building a
/// full row of page-number buttons.
class EmployeePaginationBar extends StatelessWidget {
  final int currentPage;
  final int rowCount;
  final int totalCount;
  final int pageSize;
  final bool isLoading;
  final ValueChanged<int> onPageChanged;

  const EmployeePaginationBar({
    super.key,
    required this.currentPage,
    required this.rowCount,
    required this.totalCount,
    required this.pageSize,
    required this.onPageChanged,
    this.isLoading = false,
  });

  int get _totalPages =>
      totalCount == 0 ? 1 : (totalCount / pageSize).ceil();

  @override
  Widget build(BuildContext context) {
    final totalPages = _totalPages;
    final canPrev = currentPage > 1 && !isLoading;
    final canNext = currentPage < totalPages && !isLoading;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AdminDashboardTheme.borderSoft),
        ),
      ),
      child: Row(
        children: [
          Text(
            rowCount == 0 ? 'No employees' : '$rowCount employees',
            style: const TextStyle(
              fontSize: 13,
              color: AdminDashboardTheme.textMuted,
            ),
          ),
          const Spacer(),
          _PagerButton(
            icon: Icons.chevron_left_rounded,
            onTap: canPrev ? () => onPageChanged(currentPage - 1) : null,
          ),
          const SizedBox(width: 12),
          Text(
            'Page $currentPage of $totalPages',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AdminDashboardTheme.textDark,
            ),
          ),
          const SizedBox(width: 12),
          _PagerButton(
            icon: Icons.chevron_right_rounded,
            onTap: canNext ? () => onPageChanged(currentPage + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _PagerButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _PagerButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AdminDashboardTheme.surfaceMuted,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AdminDashboardTheme.border),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled
              ? AdminDashboardTheme.textDark
              : AdminDashboardTheme.iconInactive,
        ),
      ),
    );
  }
}
