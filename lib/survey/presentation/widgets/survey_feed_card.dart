import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:my_app/core/ui/adaptive_layout.dart';

import '../../bloc/survey_employee_bloc.dart';
import '../../bloc/survey_employee_event.dart';
import '../../models/survey_models.dart';
import '../../navigation/survey_flow_controller.dart';
import '../../theme/survey_mobile_theme.dart';
import '../../theme/survey_theme.dart';
import 'survey_submission.dart';

class SurveyFeedCard extends StatelessWidget {
  const SurveyFeedCard({super.key, required this.survey});

  final SurveySummary survey;

  Future<void> _openSurvey(BuildContext context) async {
    final done = await SurveyFlowController.openTakeSurvey(context, survey.id);
    if (!context.mounted) return;

    if (done == true) {
      context.read<SurveyEmployeeBloc>().add(const SurveyEmployeeLoadActive());
      showSurveySuccessSnack(title: survey.title);
      return;
    }

    if (survey.alreadySubmitted) return;
    context.read<SurveyEmployeeBloc>().add(const SurveyEmployeeLoadActive());
  }

  @override
  Widget build(BuildContext context) {
    final mobile = AdaptiveLayout.useMobileUi(context);
    final taken = survey.alreadySubmitted;
    const success = Color(0xFF10B981);

    final accent = mobile ? SurveyMobileTheme.primary : SurveyTheme.purple;
    final textMain = mobile ? SurveyMobileTheme.textMain : SurveyTheme.textMain;
    final textMuted = mobile ? SurveyMobileTheme.textMuted : SurveyTheme.textMuted;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: taken ? success.withValues(alpha: 0.25) : SurveyTheme.divider,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openSurvey(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: taken ? const Color(0xFFECFDF5) : SurveyTheme.purpleLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        taken ? Icons.check_rounded : Icons.quiz_outlined,
                        size: 20,
                        color: taken ? success : accent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        taken ? 'Completed survey' : 'Survey request',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: textMuted,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    if (taken)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Submitted',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: success,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  survey.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: textMain,
                    height: 1.3,
                  ),
                ),
                if (survey.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    survey.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: textMuted,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      taken ? 'View your response' : 'Estimated time · 2 min',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: textMuted,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      taken ? Icons.arrow_forward_rounded : Icons.arrow_outward_rounded,
                      size: 18,
                      color: taken ? success : accent,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
