import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:my_app/employee_dashboard/widget/device_specific/v2/employee_dashboard_v2_theme.dart';

/// Dopolycolors palette for leave dashboard KPI cards.
abstract final class LeaveV2Palette {
  static const blueWhale = Color(0xFF233C4B);
  static const crusta = Color(0xFFFF7D2D);
  static const brightSun = Color(0xFFFAC840);
  static const olivine = Color(0xFFA0C382);
  static const patina = Color(0xFF5F9B8C);
}

/// Shared mint-shell chrome + filled KPI cards for employee leave screens.
class LeaveV2TopBar extends StatelessWidget {
  const LeaveV2TopBar({
    super.key,
    required this.title,
    this.onBack,
    this.actions,
  });

  final String title;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: EmployeeDashboardV2Theme.navHeight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: EmployeeDashboardV2Theme.shell,
        border: Border(
          bottom: BorderSide(color: EmployeeDashboardV2Theme.cardBorder),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack ?? () => Navigator.maybePop(context),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: EmployeeDashboardV2Theme.textDark,
            ),
            tooltip: 'Back',
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: EmployeeDashboardV2Theme.textDark,
            ),
          ),
          const Spacer(),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}

class LeaveV2KpiData {
  final String value;
  final String label;
  final String? tag;
  final Color color;
  final IconData icon;

  const LeaveV2KpiData({
    required this.value,
    required this.label,
    this.tag,
    required this.color,
    required this.icon,
  });
}

class LeaveV2KpiCard extends StatelessWidget {
  const LeaveV2KpiCard({
    super.key,
    required this.data,
    this.filled = false,
    this.onTap,
  });

  final LeaveV2KpiData data;
  final bool filled;
  final VoidCallback? onTap;

  static Color _onColor(Color bg) {
    return bg.computeLuminance() > 0.55 ? LeaveV2Palette.blueWhale : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final on = _onColor(data.color);
    final bg = filled ? data.color : data.color.withValues(alpha: 0.14);
    final border = filled
        ? data.color.withValues(alpha: 0.85)
        : data.color.withValues(alpha: 0.28);
    final valueColor = filled ? on : data.color;
    final labelColor = filled
        ? on.withValues(alpha: 0.88)
        : EmployeeDashboardV2Theme.textBody;
    final tagColor = filled
        ? on.withValues(alpha: 0.75)
        : EmployeeDashboardV2Theme.textMuted;
    final iconBg = filled
        ? on.withValues(alpha: 0.18)
        : data.color.withValues(alpha: 0.2);
    final iconColor = filled ? on : data.color;

    final card = Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: filled
            ? [
                BoxShadow(
                  color: data.color.withValues(alpha: 0.28),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(data.icon, color: iconColor, size: 18),
              ),
              if (data.tag != null)
                Text(
                  data.tag!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: tagColor,
                  ),
                ),
            ],
          ),
          const Spacer(),
          Text(
            data.value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: valueColor,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            data.label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: labelColor,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: card,
      ),
    );
  }
}

class LeaveV2KpiGrid extends StatelessWidget {
  const LeaveV2KpiGrid({
    super.key,
    required this.items,
    this.aspectRatioWide = 1.55,
    this.aspectRatioNarrow = 1.35,
    this.filled = false,
    this.onTapAt,
  });

  final List<LeaveV2KpiData> items;
  final double aspectRatioWide;
  final double aspectRatioNarrow;
  final bool filled;
  final List<VoidCallback?>? onTapAt;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth >= 900 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols.clamp(1, items.length),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: cols == 4 ? aspectRatioWide : aspectRatioNarrow,
          ),
          itemCount: items.length,
          itemBuilder: (_, i) => LeaveV2KpiCard(
            data: items[i],
            filled: filled,
            onTap: onTapAt != null && i < onTapAt!.length ? onTapAt![i] : null,
          ),
        );
      },
    );
  }
}

class LeaveV2PageTitle extends StatelessWidget {
  const LeaveV2PageTitle({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: EmployeeDashboardV2Theme.textDark,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: EmployeeDashboardV2Theme.textMuted,
            ),
          ),
        ],
      ],
    );
  }
}

class LeaveV2ContentCard extends StatelessWidget {
  const LeaveV2ContentCard({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: EmployeeDashboardV2Theme.cardDecoration(),
      child: child,
    );
  }
}
