import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:my_app/admin_dashboard/shared/admin_dashboard_theme.dart';

/// Daxarrow Dashboard v2 — admin-aligned mint shell, green accents, white bento cards.
abstract final class EmployeeDashboardV2Theme {
  static const shell = AdminDashboardTheme.shellMint;
  static const card = AdminDashboardTheme.surface;
  static const cardBorder = AdminDashboardTheme.border;
  static const cardMuted = AdminDashboardTheme.surfaceMuted;
  static const rowBorder = AdminDashboardTheme.borderSoft;
  static const surfaceAlt = AdminDashboardTheme.iconRailBg;

  static const textDark = Color(0xFF0F2E22);
  static const textMuted = Color(0xFF6B7F78);
  static const textBody = Color(0xFF5B7A6C);

  static const green = Color(0xFF10B981);
  static const greenMid = Color(0xFF059669);
  static const greenDark = Color(0xFF047857);
  static const greenLight = AdminDashboardTheme.tealLight;
  static const greenChip = Color(0xFF34D399);

  static const amber = Color(0xFFFBBF24);
  static const amberBg = Color(0xFFFEF3E2);
  static const slateBg = AdminDashboardTheme.iconRailBg;
  static const navYellow = AdminDashboardTheme.accentYellow;
  static const navYellowSoft = AdminDashboardTheme.accentYellowSoft;

  static const logoAsset = 'assets/images/logo.png';

  static const maxContentWidth = 1400.0;
  static const navHeight = 72.0;
  static const cardRadius = 22.0;
  static const cardPadding = 24.0;

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF047857).withValues(alpha: 0.12),
          blurRadius: 30,
          offset: const Offset(0, 12),
          spreadRadius: -24,
        ),
      ];

  static BoxDecoration cardDecoration({Color? background}) => BoxDecoration(
        color: background ?? card,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: cardBorder),
        boxShadow: cardShadow,
      );

  static TextStyle wordmark() => GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w800,
        fontSize: 18,
        letterSpacing: 0.05 * 18,
        color: textDark,
      );

  static TextStyle sectionTitle() => GoogleFonts.plusJakartaSans(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: textDark,
      );

  static TextStyle sectionSubtitle() => GoogleFonts.plusJakartaSans(
        fontSize: 13,
        color: textMuted,
        fontWeight: FontWeight.w500,
      );

  static TextStyle kpiValue() => GoogleFonts.plusJakartaSans(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: textDark,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static LinearGradient get brandGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [green, greenDark],
      );

  static LinearGradient get quoteGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [greenChip, green, greenDark],
        stops: [0.0, 0.5, 1.0],
      );
}
