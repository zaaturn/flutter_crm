import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/survey_models.dart';
import '../../theme/survey_mobile_theme.dart';
import '../../theme/survey_theme.dart';
import 'survey_star_rating.dart';

class SurveyFormField extends StatelessWidget {
  const SurveyFormField({
    super.key,
    required this.question,
    required this.onChanged,
    this.value,
    this.mobile = false,
  });

  final SurveyQuestion question;
  final dynamic value;
  final bool mobile;
  final ValueChanged<dynamic> onChanged;

  @override
  Widget build(BuildContext context) {
    final textMain = mobile ? SurveyMobileTheme.textMain : SurveyTheme.textMain;
    final divider = mobile ? SurveyMobileTheme.textMuted.withValues(alpha: 0.15) : SurveyTheme.divider;

    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.text + (question.isRequired ? ' *' : ''),
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: textMain,
              height: 1.4,
            ),
          ),
          if (question.questionType == QuestionType.mcq) ...[
            const SizedBox(height: 6),
            Text(
              question.allowMultiple ? 'Multiple answers enabled' : 'Single answer',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: mobile ? SurveyMobileTheme.textMuted : SurveyTheme.textMuted,
              ),
            ),
          ],
          const SizedBox(height: 14),
          switch (question.questionType) {
            QuestionType.yesNo => _yesNo(),
            QuestionType.rating => _rating(),
            QuestionType.mcq => _mcq(),
            QuestionType.unknown => const SizedBox.shrink(),
          },
          Divider(height: 32, color: divider),
        ],
      ),
    );
  }

  Widget _yesNo() {
    final accent = mobile ? SurveyMobileTheme.primaryDark : SurveyTheme.purple;
    return Row(
      children: [
        Expanded(
          child: _choiceBtn('Yes', value == true, () => onChanged(true), accent),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _choiceBtn('No', value == false, () => onChanged(false), accent),
        ),
      ],
    );
  }

  Widget _choiceBtn(String label, bool selected, VoidCallback tap, Color accent) {
    return Material(
      color: selected ? accent : SurveyTheme.surfaceAlt,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: tap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : SurveyTheme.textMain,
            ),
          ),
        ),
      ),
    );
  }

  Widget _rating() {
    return SurveyStarPicker(
      value: value as int?,
      onChanged: (v) => onChanged(v),
      mobile: mobile,
      size: 34,
    );
  }

  Widget _mcq() {
    final accent = mobile ? SurveyMobileTheme.primary : SurveyTheme.purple;
    if (question.allowMultiple) {
      final selected = (value is Set<int>) ? (value as Set<int>) : <int>{};
      return Column(
        children: question.options.map((o) {
          final checked = selected.contains(o.id);
          return CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: accent,
            value: checked,
            title: Text(
              o.text,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: mobile ? SurveyMobileTheme.textMain : SurveyTheme.textMain,
              ),
            ),
            onChanged: (v) {
              final next = Set<int>.from(selected);
              if (v == true) {
                next.add(o.id);
              } else {
                next.remove(o.id);
              }
              onChanged(next);
            },
          );
        }).toList(),
      );
    }
    final groupValue = value is int ? value as int : int.tryParse('$value');
    return Column(
      children: question.options.map((o) {
        return RadioListTile<int>(
          dense: true,
          contentPadding: EdgeInsets.zero,
          activeColor: accent,
          value: o.id,
          groupValue: groupValue,
          title: Text(
            o.text,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w600,
              color: mobile ? SurveyMobileTheme.textMain : SurveyTheme.textMain,
            ),
          ),
          onChanged: (v) => onChanged(v),
        );
      }).toList(),
    );
  }
}
