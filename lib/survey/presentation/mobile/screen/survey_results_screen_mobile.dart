import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../bloc/survey_admin_bloc.dart';
import '../../../bloc/survey_admin_event.dart';
import '../../../bloc/survey_admin_state.dart';
import '../../../models/survey_models.dart';
import '../../../theme/survey_mobile_theme.dart';
import '../../widgets/survey_delete_action.dart';
import '../../widgets/survey_rating_summary_table.dart';
import '../../widgets/survey_results_charts.dart';

class SurveyResultsScreenMobile extends StatefulWidget {
  const SurveyResultsScreenMobile({super.key, required this.surveyId});

  final int surveyId;

  @override
  State<SurveyResultsScreenMobile> createState() => _SurveyResultsScreenMobileState();
}

class _SurveyResultsScreenMobileState extends State<SurveyResultsScreenMobile> {
  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  void _loadResults() {
    context.read<SurveyAdminBloc>().add(SurveyAdminLoadResults(widget.surveyId));
  }

  bool _isCurrentResults(SurveyAdminState state) {
    final results = state.results;
    return results != null && results.surveyId == widget.surveyId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text('Results', style: GoogleFonts.manrope(fontWeight: FontWeight.w900)),
        actions: [
          BlocBuilder<SurveyAdminBloc, SurveyAdminState>(
            builder: (context, state) {
              final results = _isCurrentResults(state) ? state.results : null;
              final detail = state.detail?.id == widget.surveyId ? state.detail : null;
              if (results == null || detail?.canDelete != true) {
                return const SizedBox.shrink();
              }
              return IconButton(
                onPressed: state.actionInProgress
                    ? null
                    : () => confirmDeleteSurvey(
                          context,
                          survey: detail!,
                          popOnSuccess: true,
                        ),
                icon: const Icon(Icons.delete_outline_rounded),
                color: Colors.red.shade400,
                tooltip: 'Delete survey',
              );
            },
          ),
          IconButton(
            onPressed: _loadResults,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: BlocBuilder<SurveyAdminBloc, SurveyAdminState>(
        builder: (context, state) {
          if (state.status == SurveyAdminLoadStatus.loading && !_isCurrentResults(state)) {
            return const Center(child: CircularProgressIndicator(color: SurveyMobileTheme.primary));
          }

          final results = _isCurrentResults(state) ? state.results : null;
          if (results == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.error ?? 'No results yet', textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: _loadResults, child: const Text('Retry')),
                  ],
                ),
              ),
            );
          }

          final participation = results.participationRate;

          return RefreshIndicator(
            color: SurveyMobileTheme.primary,
            onRefresh: () async {
              context.read<SurveyAdminBloc>().add(SurveyAdminLoadResults(widget.surveyId));
              await context.read<SurveyAdminBloc>().stream.firstWhere(
                    (s) => s.status != SurveyAdminLoadStatus.loading,
                  );
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  results.title,
                  style: GoogleFonts.manrope(fontWeight: FontWeight.w900, fontSize: 22),
                ),
                const SizedBox(height: 6),
                Text(
                  '${results.responseCount} response${results.responseCount == 1 ? '' : 's'} · '
                  '${participation == null ? '—' : '${participation.toStringAsFixed(0)}%'} participation',
                  style: GoogleFonts.manrope(color: SurveyMobileTheme.textMuted),
                ),
                if (results.responseCount == 0) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: SurveyMobileTheme.card,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'No employee responses yet. Pull down to refresh after submissions.',
                      style: GoogleFonts.manrope(
                        color: SurveyMobileTheme.textMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
                if (state.detail?.status == SurveyStatus.active) ...[
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => context
                        .read<SurveyAdminBloc>()
                        .add(SurveyAdminCloseRequested(widget.surveyId)),
                    child: const Text('Close survey'),
                  ),
                ],
                if (state.detail?.canDelete == true &&
                    state.detail?.status == SurveyStatus.closed) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: state.actionInProgress
                        ? null
                        : () => confirmDeleteSurvey(
                              context,
                              survey: state.detail!,
                              popOnSuccess: true,
                            ),
                    icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400),
                    label: Text(
                      'Delete survey',
                      style: TextStyle(color: Colors.red.shade400),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red.shade300),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SurveyRatingSummaryTable(questions: results.questions, mobile: true),
                if (results.questions.isEmpty)
                  Text('No questions in this survey.', style: GoogleFonts.manrope())
                else
                  ...results.questions.map(
                    (q) => SurveyResultChart(question: q, mobile: true),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
