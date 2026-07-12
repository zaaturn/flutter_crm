import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/asset_models.dart';

/// Shared status → color mapping used across every asset screen.
abstract final class AssetStatusColors {
  static Color of(AssetStatus status) {
    switch (status) {
      case AssetStatus.free:
        return const Color(0xFF059669);
      case AssetStatus.requestPending:
        return const Color(0xFFD97706);
      case AssetStatus.engaged:
        return const Color(0xFF2563EB);
      case AssetStatus.returnRequested:
        return const Color(0xFF7C3AED);
      case AssetStatus.damaged:
        return const Color(0xFFDC2626);
      case AssetStatus.repair:
        return const Color(0xFFEA580C);
      case AssetStatus.disposed:
        return const Color(0xFF64748B);
      case AssetStatus.unknown:
        return const Color(0xFF94A3B8);
    }
  }

  static Color softOf(AssetStatus status) =>
      of(status).withValues(alpha: 0.12);
}

/// Desktop mint shell tokens (aligned with admin dashboard).
abstract final class AssetDesktopTheme {
  static const shellMint = Color(0xFFD0E3D8);
  static const surface = Colors.white;
  static const surfaceMuted = Color(0xFFF4F7F5);
  static const border = Color(0xFFE3EAE6);
  static const teal = Color(0xFF2F7D6D);
  static const tealDark = Color(0xFF1F5F52);
  static const tealLight = Color(0xFFE3F2EE);
  static const textDark = Color(0xFF1C2B26);
  static const textMuted = Color(0xFF6B7F78);
  static const danger = Color(0xFFDC2626);

  static TextStyle title({double size = 20}) => GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: FontWeight.w800,
        color: textDark,
        letterSpacing: -0.3,
      );

  static TextStyle body({double size = 13, FontWeight weight = FontWeight.w500}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: weight,
        color: textMuted,
      );

  static TextStyle label({double size = 12}) => GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: textDark,
      );
}

/// Mobile terracotta tokens (aligned with admin mobile / payroll mobile).
abstract final class AssetMobileTheme {
  static const terracotta = Color(0xFFC05C39);
  static const terracottaDark = Color(0xFFA84A2E);
  static const cream = Color(0xFFFAF9F6);
  static const creamMuted = Color(0xFFF2EDE4);
  static const textDark = Color(0xFF2C241E);
  static const textMuted = Color(0xFF8A7A6E);
  static const border = Color(0xFFE8DFD4);
  static const danger = Color(0xFFE11D48);
  static const onTerracotta = Color(0xFFFAF9F6);

  static TextStyle title({double size = 20}) => GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: FontWeight.w800,
        color: textDark,
      );

  static TextStyle body({double size = 13}) => GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: FontWeight.w500,
        color: textMuted,
      );

  static TextStyle label({double size = 12}) => GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: textDark,
      );
}
