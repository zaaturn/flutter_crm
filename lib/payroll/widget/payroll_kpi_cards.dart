import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/payroll_dashboard_model.dart';

/// THEME CONSTANTS: Matches the "Workspace Tasks" Light UI
class WorkspaceTheme {
  static const Color scaffoldBg = Color(0xFFFBFBFE);
  static const Color cardSurface = Colors.white;
  static const Color borderSubtle = Color(0xFFE8E9F1);
  static const Color shadowColor = Color(0x0A000000);

  static const Color primaryPurple = Color(0xFF6F34DC);
  static const Color textMain = Color(0xFF222329);
  static const Color textMuted = Color(0xFF6A6B74);
  static const Color textLightMuted = Color(0xFFA1A3AE);

  static const Color greenStatusBg = Color(0xFFE6F8F2);
  static const Color greenStatusText = Color(0xFF1CB180);
  static const Color orangeStatusBg = Color(0xFFFFF7EA);
  static const Color orangeStatusText = Color(0xFFFDB53D);
}

class PayrollKpiCards extends StatelessWidget {
  const PayrollKpiCards({super.key, required this.dashboard});

  final PayrollDashboardModel dashboard;

  @override
  Widget build(BuildContext context) {
    final int eligible =
        dashboard.totalEligibleUsers ?? dashboard.totalEmployees;
    final int displayHeadcount = (eligible == 0)
        ? (dashboard.paidRecordsCount + dashboard.totalPending)
        : eligible;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Switch between Row and Column based on screen width
        final isLarge = constraints.maxWidth > 900;

        final cards = [
          _WorkspaceKpiCard(
            title: 'TOTAL HEADCOUNT',
            count: displayHeadcount,
            metaText: 'Total registered staff',
            icon: Icons.badge_outlined,
            footerWidget: Text(
              'Active in system',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: WorkspaceTheme.textMuted,
              ),
            ),
          ),
          _WorkspaceKpiCard(
            title: 'TOTAL PAID',
            count: dashboard.paidRecordsCount,
            metaText: 'Monthly disbursement',
            icon: Icons.payments_outlined,
            footerWidget: _StatusBadge(
              label: 'COMPLETED',
              backgroundColor: WorkspaceTheme.greenStatusBg,
              textColor: WorkspaceTheme.greenStatusText,
            ),
          ),
          _WorkspaceKpiCard(
            title: 'UNSET / PENDING',
            count: dashboard.unsetCount ?? dashboard.totalPending,
            metaText: dashboard.unsetCount != null
                ? 'Paid status not set (unset)'
                : 'Awaiting processing',
            icon: Icons.hourglass_top_rounded,
            footerWidget: _StatusBadge(
              label: 'PENDING',
              backgroundColor: WorkspaceTheme.orangeStatusBg,
              textColor: WorkspaceTheme.orangeStatusText,
            ),
          ),
        ];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: isLarge
              ? Row(
            children: cards
                .map((card) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: card,
              ),
            ))
                .toList(),
          )
              : Column(
            children: cards
                .map((card) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: card,
            ))
                .toList(),
          ),
        );
      },
    );
  }

  static String _format(int n) => NumberFormat('#,##0', 'en_US').format(n);
}

class _WorkspaceKpiCard extends StatelessWidget {
  const _WorkspaceKpiCard({
    required this.title,
    required this.count,
    required this.metaText,
    required this.icon,
    required this.footerWidget,
  });

  final String title;
  final int count;
  final String metaText;
  final IconData icon;
  final Widget footerWidget;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: WorkspaceTheme.cardSurface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: WorkspaceTheme.borderSubtle),
        boxShadow: const [
          BoxShadow(
            color: WorkspaceTheme.shadowColor,
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: WorkspaceTheme.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
              Icon(icon, size: 20, color: WorkspaceTheme.textLightMuted),
            ],
          ),
          const SizedBox(height: 12),

          // Count Display
          Text(
            PayrollKpiCards._format(count),
            style: GoogleFonts.inter(
              fontSize: 52,
              fontWeight: FontWeight.w800,
              height: 1.0,
              letterSpacing: -2,
              color: WorkspaceTheme.textMain,
            ),
          ),
          const SizedBox(height: 16),

          // "Assign to" / Info Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: WorkspaceTheme.primaryPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 14, color: WorkspaceTheme.primaryPurple),
                const SizedBox(width: 6),
                Text(
                  metaText,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: WorkspaceTheme.primaryPurple,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Divider(color: WorkspaceTheme.borderSubtle, height: 1),
          const SizedBox(height: 16),

          // Footer Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              footerWidget,
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 14, color: WorkspaceTheme.textLightMuted),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('MMM dd').format(DateTime.now()),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: WorkspaceTheme.textLightMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}