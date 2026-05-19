import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


abstract final class BillingLeaveMobileTheme {
  static const Color bg = Color(0xFFFEF7F1);          // Warm Cream Background
  static const Color surface = Color(0xFFFFFDFB);     // Paper White Surface
  static const Color surfaceMuted = Color(0xFFF5E6DA); // Clay Tint
  static const Color primary = Color(0xFF0C56D0);      // Elite Blue
  static const Color accent = Color(0xFFB14D1E);       // Temple Orange
  static const Color text = Color(0xFF1A1C1E);         // Deep Ink
  static const Color muted = Color(0xFF74777F);        // Slate Muted
  static const Color border = Color(0x1A000000);
  static const Color mintCard = Color(0xFFD1EBE5);     // Top Box from image
  static const Color lavenderCard = Color(0xFFE5E7FF); // Bottom Box from image
  static const Color deepInk = Color(0xFF1A1C1E);// Soft Black Definition

  static BoxDecoration cardDecoration() => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: border),
    boxShadow: [
      BoxShadow(
        color: accent.withOpacity(0.04),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  );

  static TextStyle overline() => GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w800,
    color: muted,
    letterSpacing: 1.2,
  );

  static TextStyle titleLarge() => GoogleFonts.manrope(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: text,
    letterSpacing: -0.5,
  );

  static TextStyle body() => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: muted,
  );

  static TextStyle cardTitle() => GoogleFonts.manrope(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: text,
  );

  static TextStyle cardSubtitle() => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: muted,
  );
}