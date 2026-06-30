import 'package:flutter/material.dart';

/// White rounded panel on the mint canvas — one per dashboard zone.
class AdminDashboardPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsets? margin;
  final double? width;
  final double? height;

  const AdminDashboardPanel({
    super.key,
    required this.child,
    this.margin,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        color: AdminDashboardTheme.surface,
        borderRadius: BorderRadius.circular(AdminDashboardTheme.panelRadius),
        border: Border.all(color: AdminDashboardTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AdminDashboardTheme.panelRadius),
        child: child,
      ),
    );
  }
}

/// Shared admin shell tokens.
abstract final class AdminDashboardTheme {
  static const shellMint = Color(0xFFD0E3D8);
  static const surface = Colors.white;
  static const surfaceMuted = Color(0xFFF4F7F5);
  static const border = Color(0xFFE3EAE6);
  static const borderSoft = Color(0xFFEDF2EF);

  static const teal = Color(0xFF2F7D6D);
  static const tealDark = Color(0xFF1F5F52);
  static const tealLight = Color(0xFFE3F2EE);

  static const accentYellow = Color(0xFFF5C842);
  static const accentYellowSoft = Color(0xFFFFF4CC);

  static const iconRailBg = Color(0xFFF0F4F2);
  static const iconInactive = Color(0xFF9AABA3);
  static const textDark = Color(0xFF1C2B26);
  static const textMuted = Color(0xFF6B7F78);

  static const shellPadding = 12.0;
  static const panelGap = 10.0;
  static const panelRadius = 20.0;
  static const railWidth = 88.0;
  static const calendarWidth = 360.0;
  static const topBarHeight = 52.0;

  static TextStyle companyTitle() => const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: textDark,
        letterSpacing: -0.2,
      );

  static TextStyle profileName() => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: textDark,
      );
}
