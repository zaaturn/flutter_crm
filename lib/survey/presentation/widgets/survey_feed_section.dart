import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:my_app/core/ui/adaptive_layout.dart';
import 'package:my_app/employee_dashboard/widget/employee_feed_chrome.dart';

import '../../bloc/survey_employee_bloc.dart';
import '../../bloc/survey_employee_event.dart';
import '../../bloc/survey_employee_state.dart';
import '../../theme/survey_mobile_theme.dart';
import 'survey_feed_card.dart';

/// Active surveys block for employee home / feed.
class SurveyFeedSection extends StatefulWidget {
  const SurveyFeedSection({super.key, this.compact = false});

  final bool compact;

  @override
  State<SurveyFeedSection> createState() => _SurveyFeedSectionState();
}

class _SurveyFeedSectionState extends State<SurveyFeedSection> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<SurveyEmployeeBloc>().add(const SurveyEmployeeLoadActive());
    });
  }

  @override
  Widget build(BuildContext context) {
    final mobile = AdaptiveLayout.useMobileUi(context);
    final chrome = EmployeeFeedChrome.of(context);
    final accent = mobile ? SurveyMobileTheme.primary : chrome.accent;
    final textMain = mobile ? SurveyMobileTheme.textMain : const Color(0xFF0F172A);
    final textMuted = mobile ? SurveyMobileTheme.textMuted : const Color(0xFF64748B);
    final errorBg = mobile ? SurveyMobileTheme.fieldFill : chrome.accentLight;

    return BlocBuilder<SurveyEmployeeBloc, SurveyEmployeeState>(
      builder: (context, state) {
        if (state.status == SurveyEmployeeStatus.loading &&
            state.activeSurveys.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: accent,
                ),
              ),
            ),
          );
        }

        if (state.status == SurveyEmployeeStatus.failure &&
            state.activeSurveys.isEmpty) {
          return _ErrorBox(
            message: state.error ?? 'Could not load surveys',
            background: errorBg,
            textColor: textMuted,
            accent: accent,
            onRetry: () => context
                .read<SurveyEmployeeBloc>()
                .add(const SurveyEmployeeLoadActive()),
          );
        }

        if (state.activeSurveys.isEmpty) {
          return const SizedBox.shrink();
        }

        final cards = state.activeSurveys
            .map((s) => SurveyFeedCard(survey: s))
            .toList();

        if (widget.compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.quiz_outlined, size: 22, color: accent),
                  const SizedBox(width: 8),
                  Text(
                    'Surveys',
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: textMain,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...cards,
            ],
          );
        }

        return Column(children: cards);
      },
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({
    required this.message,
    required this.onRetry,
    required this.background,
    required this.textColor,
    required this.accent,
  });

  final String message;
  final VoidCallback onRetry;
  final Color background;
  final Color textColor;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.manrope(
                fontSize: 13,
                color: textColor,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(foregroundColor: accent),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
