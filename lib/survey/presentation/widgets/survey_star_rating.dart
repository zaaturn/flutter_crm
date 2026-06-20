import 'package:flutter/material.dart';

import '../../theme/survey_mobile_theme.dart';
import '../../theme/survey_theme.dart';

/// Maps a 1–5 average to a human-readable level (High / Low etc.).
class SurveyRatingLevel {
  SurveyRatingLevel._();

  static String label(double average) {
    if (average >= 4.5) return 'Very High';
    if (average >= 3.5) return 'High';
    if (average >= 2.5) return 'Medium';
    if (average >= 1.5) return 'Low';
    return 'Very Low';
  }

  static Color color(double average) {
    if (average >= 4.5) return const Color(0xFF059669);
    if (average >= 3.5) return const Color(0xFF10B981);
    if (average >= 2.5) return const Color(0xFFF59E0B);
    if (average >= 1.5) return const Color(0xFFF97316);
    return const Color(0xFFEF4444);
  }
}

/// Read-only star row — fills every star up to [value].
class SurveyStarDisplay extends StatelessWidget {
  const SurveyStarDisplay({
    super.key,
    required this.value,
    this.size = 20,
    this.color,
    this.mobile = false,
  });

  final int value;
  final double size;
  final Color? color;
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? (mobile ? SurveyMobileTheme.primary : SurveyTheme.purple);
    final muted = mobile ? SurveyMobileTheme.textMuted : SurveyTheme.textMuted;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < value.clamp(0, 5);
        return Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Icon(
            filled ? Icons.star_rounded : Icons.star_outline_rounded,
            size: size,
            color: filled ? accent : muted.withValues(alpha: 0.45),
          ),
        );
      }),
    );
  }
}

/// Interactive star picker — tap star N to fill stars 1..N.
class SurveyStarPicker extends StatelessWidget {
  const SurveyStarPicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.mobile = false,
    this.size = 36,
  });

  final int? value;
  final ValueChanged<int> onChanged;
  final bool mobile;
  final double size;

  @override
  Widget build(BuildContext context) {
    final accent = mobile ? SurveyMobileTheme.primary : SurveyTheme.purple;
    final muted = mobile ? SurveyMobileTheme.textMuted : SurveyTheme.textMuted;
    final selected = value ?? 0;

    return Row(
      children: List.generate(5, (i) {
        final star = i + 1;
        final filled = star <= selected;
        return InkWell(
          onTap: () => onChanged(star),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Icon(
              filled ? Icons.star_rounded : Icons.star_outline_rounded,
              color: filled ? accent : muted.withValues(alpha: 0.45),
              size: size,
            ),
          ),
        );
      }),
    );
  }
}
