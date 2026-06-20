import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/survey_models.dart';
import '../../theme/survey_mobile_theme.dart';
import '../../theme/survey_theme.dart';
import 'survey_star_rating.dart';

/// Workday-style summary table for rating questions in admin results.
class SurveyRatingSummaryTable extends StatelessWidget {
  const SurveyRatingSummaryTable({
    super.key,
    required this.questions,
    this.mobile = false,
  });

  final List<QuestionResult> questions;
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    final ratingQuestions =
        questions.where((q) => q.questionType == QuestionType.rating && q.rating != null).toList();
    if (ratingQuestions.isEmpty) return const SizedBox.shrink();

    final accent = mobile ? SurveyMobileTheme.primary : SurveyTheme.purple;
    final divider = mobile ? SurveyMobileTheme.textMuted.withValues(alpha: 0.15) : SurveyTheme.divider;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Text(
              'Rating summary',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: mobile ? SurveyMobileTheme.textMain : SurveyTheme.textMain,
              ),
            ),
          ),
          Divider(height: 1, color: divider),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Question',
                    style: _headerStyle(mobile),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Level',
                    style: _headerStyle(mobile),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Rating',
                    style: _headerStyle(mobile),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: divider),
          ...ratingQuestions.asMap().entries.map((entry) {
            final i = entry.key;
            final q = entry.value;
            final avg = q.rating!.average;
            final rounded = avg.round().clamp(1, 5);
            final level = SurveyRatingLevel.label(avg);
            final levelColor = SurveyRatingLevel.color(avg);
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          q.text,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: mobile ? SurveyMobileTheme.textMain : SurveyTheme.textMain,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          level,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: levelColor,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: SurveyStarDisplay(
                            value: rounded,
                            size: 18,
                            color: accent,
                            mobile: mobile,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < ratingQuestions.length - 1) Divider(height: 1, color: divider),
              ],
            );
          }),
        ],
      ),
    );
  }

  TextStyle _headerStyle(bool mobile) {
    return GoogleFonts.plusJakartaSans(
      fontWeight: FontWeight.w700,
      fontSize: 12,
      color: mobile ? SurveyMobileTheme.textMuted : SurveyTheme.textMuted,
      letterSpacing: 0.3,
    );
  }
}
