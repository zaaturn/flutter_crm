import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../bloc/survey_employee_bloc.dart';
import '../../../bloc/survey_employee_event.dart';
import '../../../models/survey_models.dart';
import '../../../navigation/survey_flow_controller.dart';
import '../../../theme/survey_mobile_theme.dart';
import '../../widgets/survey_submission.dart';

class SurveyFeedCardMobile extends StatelessWidget {
  const SurveyFeedCardMobile({super.key, required this.survey});

  final SurveySummary survey;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SurveyMobileTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: SurveyMobileTheme.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: SurveyMobileTheme.fieldFill,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.assignment_outlined, color: SurveyMobileTheme.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Survey',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: SurveyMobileTheme.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            survey.title,
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w900,
              fontSize: 17,
              color: SurveyMobileTheme.textMain,
            ),
          ),
          if (survey.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              survey.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                fontSize: 13,
                color: SurveyMobileTheme.textMuted,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final done = await SurveyFlowController.openTakeSurvey(context, survey.id);
                if (done == true && context.mounted) {
                  context.read<SurveyEmployeeBloc>().add(
                        const SurveyEmployeeLoadActive(),
                      );
                  showSurveySuccessSnack(title: survey.title);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: SurveyMobileTheme.primaryDark,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('Take Survey', style: GoogleFonts.manrope(fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }
}
