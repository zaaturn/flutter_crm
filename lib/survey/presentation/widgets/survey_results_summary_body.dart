import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../bloc/survey_admin_bloc.dart';
import '../../bloc/survey_admin_event.dart';
import '../../bloc/survey_admin_state.dart';
import '../../models/survey_models.dart';
import '../../theme/survey_theme.dart';
import 'survey_rating_summary_table.dart';
import 'survey_results_charts.dart';
import 'survey_text_results_list.dart';

class SurveyResultsSummaryBody extends StatelessWidget {
  const SurveyResultsSummaryBody({
    super.key,
    required this.results,
    required this.state,
    required this.surveyId,
    this.mobile = false,
  });

  final SurveyResults results;
  final SurveyAdminState state;
  final int surveyId;
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    final detail = state.detail?.id == surveyId ? state.detail : null;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
          horizontal: mobile ? 16 : 24,
          vertical: mobile ? 20 : 28
      ),
      children: [
        // Title and Status Layout Section
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    results.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: mobile ? 20 : 24,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.5,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (detail != null) ...[
              const SizedBox(width: 12),
              _buildStatusBadge(detail.status),
            ],
          ],
        ),
        const SizedBox(height: 24),

        _buildMetricCard(
          label: 'Total Responses',
          value: '${results.responseCount}',
          icon: Icons.people_alt_rounded,
        ),
        const SizedBox(height: 16),

        // Elegant Alert for Empty Response States
        if (results.responseCount == 0) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SurveyTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: Color(0xFF64748B), size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No employee responses yet. Analytics will update automatically upon submissions.',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF475569),
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        const SizedBox(height: 12),

        // Data Breakdown Tables / Components
        SurveyRatingSummaryTable(questions: results.questions, mobile: mobile),
        const SizedBox(height: 24),

        if (results.questions.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Text(
                'No questions defined in this survey schema.',
                style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 14),
              ),
            ),
          )
        else
          ...results.questions.map((q) {
            if (q.questionType == QuestionType.text) {
              return SurveyTextResultsList(question: q, mobile: mobile);
            }
            return SurveyResultChart(question: q, mobile: mobile);
          }),

        // Primary Administrative Call-to-actions
        if (detail?.status == SurveyStatus.active) ...[
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: state.actionInProgress
                ? null
                : () => context.read<SurveyAdminBloc>().add(
              SurveyAdminCloseRequested(surveyId),
            ),
            icon: const Icon(Icons.lock_outline_rounded, size: 16),
            label: Text(
              'Close Survey and Finalize Metrics',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
              backgroundColor: const Color(0xFFFEF2F2),
              side: const BorderSide(color: Color(0xFFFCA5A5)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ],
      ],
    );
  }

  // Beautiful structural metric item wrapper
  Widget _buildMetricCard({required String label, required String value, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF475569), size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Refined pill indicators representing states cleanly
  Widget _buildStatusBadge(SurveyStatus status) {
    final isActive = status == SurveyStatus.active;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: isActive ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Text(
        isActive ? 'Active' : 'Closed',
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isActive ? const Color(0xFF15803D) : const Color(0xFF475569),
        ),
      ),
    );
  }
}