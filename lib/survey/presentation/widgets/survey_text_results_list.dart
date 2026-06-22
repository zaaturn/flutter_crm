import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/survey_models.dart';
import '../../theme/survey_mobile_theme.dart';
import '../../theme/survey_theme.dart';

/// Lists descriptive text answers for admin results.
class SurveyTextResultsList extends StatelessWidget {
  const SurveyTextResultsList({
    super.key,
    required this.question,
    this.mobile = false,
  });

  final QuestionResult question;
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    if (question.questionType != QuestionType.text) {
      return const SizedBox.shrink();
    }

    final data = question.textResult;
    final accent = mobile ? SurveyMobileTheme.primary : SurveyTheme.purple;
    final divider = mobile ? SurveyMobileTheme.textMuted.withValues(alpha: 0.15) : SurveyTheme.divider;
    final textMain = mobile ? SurveyMobileTheme.textMain : SurveyTheme.textMain;
    final textMuted = mobile ? SurveyMobileTheme.textMuted : SurveyTheme.textMuted;

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
              color: textMain,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Descriptive text · ${data?.total ?? 0} response${(data?.total ?? 0) == 1 ? '' : 's'}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textMuted,
            ),
          ),
          const SizedBox(height: 14),
          if (data == null || data.answers.isEmpty)
            Text(
              'No text responses yet.',
              style: GoogleFonts.plusJakartaSans(color: textMuted),
            )
          else
            ...data.answers.asMap().entries.map(
                  (e) => _AnswerCard(
                    answer: e.value,
                    index: e.key,
                    accent: accent,
                    textMain: textMain,
                    textMuted: textMuted,
                    mobile: mobile,
                  ),
                ),
        ],
      ),
    );
  }
}

class _AnswerCard extends StatefulWidget {
  const _AnswerCard({
    required this.answer,
    required this.index,
    required this.accent,
    required this.textMain,
    required this.textMuted,
    required this.mobile,
  });

  final TextAnswerResult answer;
  final int index;
  final Color accent;
  final Color textMain;
  final Color textMuted;
  final bool mobile;

  @override
  State<_AnswerCard> createState() => _AnswerCardState();
}

class _AnswerCardState extends State<_AnswerCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final preview = widget.answer.text.length > 160 && !_expanded
        ? '${widget.answer.text.substring(0, 160).trim()}…'
        : widget.answer.text;
    final canExpand = widget.answer.text.length > 160;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: widget.mobile ? SurveyMobileTheme.card : SurveyTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.accent.withValues(alpha: 0.18)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canExpand ? () => setState(() => _expanded = !_expanded) : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.answer.employeeName ?? 'Response ${widget.index + 1}',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: widget.textMain,
                        ),
                      ),
                    ),
                    if (widget.answer.wordCount > 0)
                      Text(
                        '${widget.answer.wordCount} words',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: widget.textMuted,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  preview,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    height: 1.45,
                    color: widget.textMain,
                  ),
                ),
                if (canExpand)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _expanded ? 'Show less' : 'Show full answer',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: widget.accent,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
