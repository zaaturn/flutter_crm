import 'package:flutter/material.dart';

class SurveyTheme {
  SurveyTheme._();

  static const purple = Color(0xFF7C3AED);
  static const purpleDark = Color(0xFF4C1D95);
  static const purpleLight = Color(0xFFF5F3FF);
  static const background = Colors.white;
  static const surface = Color(0xFFF8FAFC);
  static const surfaceAlt = Color(0xFFF1F5F9);
  static const divider = Color(0xFFE2E8F0);
  static const border = Color(0xFFE2E8F0);
  static const textMain = Color(0xFF0F172A);
  static const textMuted = Color(0xFF64748B);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);

  static Color statusColor(SurveyStatusLike status) {
    switch (status) {
      case SurveyStatusLike.draft:
        return textMuted;
      case SurveyStatusLike.active:
        return success;
      case SurveyStatusLike.closed:
        return purpleDark;
    }
  }
}

enum SurveyStatusLike { draft, active, closed }

SurveyStatusLike statusLikeFromString(String? s) {
  switch (s?.toLowerCase()) {
    case 'draft':
      return SurveyStatusLike.draft;
    case 'active':
      return SurveyStatusLike.active;
    case 'closed':
      return SurveyStatusLike.closed;
    default:
      return SurveyStatusLike.draft;
  }
}
