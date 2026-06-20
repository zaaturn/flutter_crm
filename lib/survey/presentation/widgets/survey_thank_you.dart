import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/survey_theme.dart';

/// Shown after the current user has already submitted this survey.
class SurveyThankYouView extends StatelessWidget {
  const SurveyThankYouView({
    super.key,
    required this.surveyTitle,
    this.mobile = false,
  });

  final String surveyTitle;
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: EdgeInsets.all(mobile ? 24 : 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                color: SurveyTheme.success,
                size: 56,
              ),
              const SizedBox(height: 16),
              Text(
                'Response submitted',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: mobile ? 22 : 20,
                  color: SurveyTheme.textMain,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You already submitted "$surveyTitle".',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: SurveyTheme.textMuted,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
