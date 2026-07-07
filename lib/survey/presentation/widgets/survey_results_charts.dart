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
    if (question.questionType == QuestionType.text) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      // High-End SaaS Card Container
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  question.text,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: mobile ? SurveyMobileTheme.textMain : const Color(0xFF0F172A),
                    letterSpacing: -0.2,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          switch (question.questionType) {
            QuestionType.yesNo => _yesNo(question.yesNo, accent),
            QuestionType.rating => _rating(question.rating, accent),
            QuestionType.mcq => _mcq(question.mcq, accent),
            QuestionType.text => const SizedBox.shrink(),
            QuestionType.unknown => _emptyState('No data available'),
          },
        ],
      ),
    );
  }

  Widget _emptyState(String message) {
    return Text(
      message,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF94A3B8),
      ),
    );
  }

  Widget _yesNo(YesNoResult? r, Color accent) {
    if (r == null) return _emptyState('No responses collected');
    return Column(
      children: [
        _bar('Yes', r.yes, r.yesPct, accent),
        const SizedBox(height: 12),
        _bar('No', r.no, r.noPct, const Color(0xFF94A3B8)), // Premium gray for alternate action
      ],
    );
  }

  Widget _rating(RatingResult? r, Color accent) {
    if (r == null) return _emptyState('No ratings recorded');
    final rounded = r.average.round().clamp(1, 5);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: SurveyTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          SurveyStarDisplay(value: rounded, size: 18, color: accent, mobile: mobile),
          const SizedBox(width: 12),
          Text(
            SurveyRatingLevel.label(r.average),
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: SurveyRatingLevel.color(r.average),
            ),
          ),
          const Spacer(),
          Text(
            '${r.average.toStringAsFixed(1)} average',
            style: GoogleFonts.inter(
              color: const Color(0xFF475569),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _mcq(McqResult? r, Color accent) {
    if (r == null || r.options.isEmpty) return _emptyState('No choices tracked');
    return Column(
      children: r.options
          .map((o) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
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
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: const Color(0xFF334155),
                ),
              ),
            ),
            Row(
              children: [
                Text(
                  '$count responses',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${pct.toStringAsFixed(0)}%',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: (pct / 100).clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: const Color(0xFFF1F5F9), // Cleaner neutral rail track
            color: color,
          ),
        ),
      ],
    );
  }
}