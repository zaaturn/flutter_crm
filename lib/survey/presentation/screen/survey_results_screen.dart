import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../bloc/survey_admin_bloc.dart';
import '../../bloc/survey_admin_event.dart';
import '../../bloc/survey_admin_state.dart';
import '../../models/survey_models.dart';
import '../../theme/survey_theme.dart';
import '../widgets/survey_delete_action.dart';
import '../widgets/survey_rating_summary_table.dart';
import '../widgets/survey_results_charts.dart';

class SurveyResultsScreen extends StatefulWidget {
  const SurveyResultsScreen({super.key, required this.surveyId});

  final int surveyId;

  @override
  State<SurveyResultsScreen> createState() => _SurveyResultsScreenState();
}

class _SurveyResultsScreenState extends State<SurveyResultsScreen> {
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
      backgroundColor: SurveyTheme.background,
      appBar: AppBar(
        backgroundColor: SurveyTheme.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text('Results', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
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
            tooltip: 'Refresh results',
          ),
        ],
      ),
      body: BlocConsumer<SurveyAdminBloc, SurveyAdminState>(
        listenWhen: (p, c) => c.error != null && c.error != p.error,
        listener: (context, state) {
          if (state.error != null && !_isCurrentResults(state)) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        builder: (context, state) {
          if (state.status == SurveyAdminLoadStatus.loading && !_isCurrentResults(state)) {
            return const Center(child: CircularProgressIndicator(color: SurveyTheme.purple));
          }

          final results = _isCurrentResults(state) ? state.results : null;
          if (results == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.error ?? 'No results yet'),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: _loadResults, child: const Text('Retry')),
                  ],
                ),
              ),
            );
          }

          final detail = state.detail?.id == widget.surveyId ? state.detail : null;
          final participation = results.participationRate;

          return RefreshIndicator(
            color: SurveyTheme.purple,
            onRefresh: () async {
              context.read<SurveyAdminBloc>().add(SurveyAdminLoadResults(widget.surveyId));
              await context.read<SurveyAdminBloc>().stream.firstWhere(
                    (s) => s.status != SurveyAdminLoadStatus.loading,
                  );
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(32),
              children: [
                Text(
                  results.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    color: SurveyTheme.textMain,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${results.responseCount} response${results.responseCount == 1 ? '' : 's'} · '
                  '${participation == null ? '—' : '${participation.toStringAsFixed(0)}%'} participation',
                  style: const TextStyle(color: SurveyTheme.textMuted),
                ),
                if (results.responseCount == 0) ...[
                  const SizedBox(height: 12),
                  Text(
                    'No employee responses yet. Results will update after submissions.',
                    style: GoogleFonts.plusJakartaSans(
                      color: SurveyTheme.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SurveyRatingSummaryTable(questions: results.questions),
                if (detail?.status == SurveyStatus.active) ...[
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: state.actionInProgress
                        ? null
                        : () => context
                            .read<SurveyAdminBloc>()
                            .add(SurveyAdminCloseRequested(widget.surveyId)),
                    child: const Text('Close survey'),
                  ),
                ],
                if (detail?.canDelete == true && detail?.status == SurveyStatus.closed) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: state.actionInProgress
                        ? null
                        : () => confirmDeleteSurvey(
                              context,
                              survey: detail!,
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
                const SizedBox(height: 20),
                if (results.questions.isEmpty)
                  const Text('No questions in this survey.')
                else
                  ...results.questions.map((q) => SurveyResultChart(question: q)),
              ],
            ),
          );
        },
      ),
    );
  }
}
