import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/survey_models.dart';
import '../../theme/survey_theme.dart';
import '../../theme/survey_mobile_theme.dart';
import 'survey_star_rating.dart';

class SurveyResultChart extends StatelessWidget {
  const SurveyResultChart({super.key, required this.question, this.mobile = false});

  final QuestionResult question;
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    final accent = mobile ? SurveyMobileTheme.primary : SurveyTheme.purple;
    final divider = mobile ? SurveyMobileTheme.textMuted.withValues(alpha: 0.15) : SurveyTheme.divider;

    if (question.questionType == QuestionType.rating && question.rating != null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: divider)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.text,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: mobile ? SurveyMobileTheme.textMain : SurveyTheme.textMain,
            ),
          ),
          const SizedBox(height: 14),
          switch (question.questionType) {
            QuestionType.yesNo => _yesNo(question.yesNo, accent),
            QuestionType.rating => _rating(question.rating, accent),
            QuestionType.mcq => _mcq(question.mcq, accent),
            QuestionType.unknown => const Text('No data'),
          },
        ],
      ),
    );
  }

  Widget _yesNo(YesNoResult? r, Color accent) {
    if (r == null) return const Text('No responses');
    return Column(
      children: [
        _bar('Yes', r.yes, r.yesPct, accent),
        const SizedBox(height: 8),
        _bar('No', r.no, r.noPct, accent.withValues(alpha: 0.55)),
      ],
    );
  }

  Widget _rating(RatingResult? r, Color accent) {
    if (r == null) return const Text('No responses');
    final rounded = r.average.round().clamp(1, 5);
    return Row(
      children: [
        SurveyStarDisplay(value: rounded, size: 20, color: accent, mobile: mobile),
        const SizedBox(width: 12),
        Text(
          SurveyRatingLevel.label(r.average),
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            color: SurveyRatingLevel.color(r.average),
          ),
        ),
        const Spacer(),
        Text(
          '${r.average.toStringAsFixed(1)} avg',
          style: const TextStyle(color: SurveyTheme.textMuted, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _mcq(McqResult? r, Color accent) {
    if (r == null || r.options.isEmpty) return const Text('No responses');
    return Column(
      children: r.options
          .map((o) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _bar(o.text, o.count, o.pct, accent),
              ))
          .toList(),
    );
  }

  Widget _bar(String label, int count, double pct, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
            Text('$count (${pct.toStringAsFixed(0)}%)'),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (pct / 100).clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: color.withValues(alpha: 0.12),
            color: color,
          ),
        ),
      ],
    );
  }
}
