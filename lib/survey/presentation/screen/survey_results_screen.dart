import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../bloc/survey_admin_bloc.dart';
import '../../bloc/survey_admin_event.dart';
import '../../bloc/survey_admin_state.dart';
import '../../models/survey_models.dart';
import '../widgets/survey_delete_action.dart';
import '../widgets/survey_results_summary_body.dart';
import '../widgets/survey_user_responses_tab.dart';
import '../widgets/survey_admin_shell.dart';
import '../widgets/survey_filter_rail.dart';
import '../../theme/survey_theme.dart';
import '../../utils/survey_pdf_download.dart';

class SurveyResultsScreen extends StatefulWidget {
  const SurveyResultsScreen({super.key, required this.surveyId});

  final int surveyId;

  @override
  State<SurveyResultsScreen> createState() => _SurveyResultsScreenState();
}

class _SurveyResultsScreenState extends State<SurveyResultsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(_onTabChanged);
    _loadResults();
  }

  @override
  void dispose() {
    _tabs.removeListener(_onTabChanged);
    _tabs.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabs.index == 1 && !_tabs.indexIsChanging) {
      _loadUserResponsesIfNeeded();
    }
  }

  void _loadResults() {
    context.read<SurveyAdminBloc>().add(SurveyAdminLoadResults(widget.surveyId));
  }

  void _loadUserResponsesIfNeeded() {
    final state = context.read<SurveyAdminBloc>().state;
    if (!_isCurrentResults(state)) return;
    if (state.individualResponses.isNotEmpty) return;
    context
        .read<SurveyAdminBloc>()
        .add(SurveyAdminLoadIndividualResponses(widget.surveyId));
  }

  bool _isCurrentResults(SurveyAdminState state) {
    final results = state.results;
    return results != null && results.surveyId == widget.surveyId;
  }

  Future<void> _refresh() async {
    context.read<SurveyAdminBloc>().add(SurveyAdminLoadResults(widget.surveyId));
    await context.read<SurveyAdminBloc>().stream.firstWhere(
          (s) => s.status != SurveyAdminLoadStatus.loading,
    );
    if (_tabs.index == 1) {
      if (!mounted) return;
      context
          .read<SurveyAdminBloc>()
          .add(SurveyAdminLoadIndividualResponses(widget.surveyId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SurveyAdminBloc, SurveyAdminState>(
      builder: (context, state) {
        return SurveyAdminShell(
          title: 'Survey Analytics',
          onBack: () => Navigator.of(context).pop(),
          rail: SurveyFilterRail(
            selected: state.filter,
            popOnFilterChange: true,
            onBack: () => Navigator.of(context).pop(),
          ),
          actions: [
        BlocBuilder<SurveyAdminBloc, SurveyAdminState>(
          builder: (context, state) {
            final results = _isCurrentResults(state) ? state.results : null;
            final detail =
                state.detail?.id == widget.surveyId ? state.detail : null;
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
              icon: const Icon(Icons.delete_outline_rounded,
                  color: SurveyTheme.danger),
              tooltip: 'Delete survey',
            );
          },
        ),
        IconButton(
          onPressed: () => SurveyPdfDownload.downloadFullReport(
            context,
            surveyId: widget.surveyId,
          ),
          icon: const Icon(Icons.download_rounded, color: SurveyTheme.primary),
          tooltip: 'Download full report',
        ),
        IconButton(
          onPressed: _refresh,
          icon: const Icon(Icons.refresh_rounded, color: SurveyTheme.textMuted),
          tooltip: 'Refresh results',
        ),
        const SizedBox(width: 8),
      ],
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            color: SurveyTheme.surface,
            child: Container(
              height: 46,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: SurveyTheme.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SurveyTheme.border),
              ),
              child: TabBar(
                controller: _tabs,
                labelColor: SurveyTheme.textMain,
                unselectedLabelColor: SurveyTheme.textMuted,
                labelStyle: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
                unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: SurveyTheme.accentYellow,
                  borderRadius: BorderRadius.circular(9),
                ),
                tabs: const [
                  Tab(text: 'Overview Metrics'),
                  Tab(text: 'Respondent Roster'),
                ],
              ),
            ),
          ),
          Expanded(
            child: BlocConsumer<SurveyAdminBloc, SurveyAdminState>(
              listenWhen: (p, c) => c.error != null && c.error != p.error,
              listener: (context, state) {
                if (state.error != null && !_isCurrentResults(state)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: SurveyTheme.textMain,
                      margin: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      content: Text(state.error!),
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state.status == SurveyAdminLoadStatus.loading && !_isCurrentResults(state)) {
                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: SurveyTheme.primary,
                    ),
                  );
                }

                final results = _isCurrentResults(state) ? state.results : null;
                if (results == null) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 340),
                      child: Container(
                        margin: const EdgeInsets.all(24),
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: SurveyTheme.background,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: SurveyTheme.border),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 56,
                              width: 56,
                              decoration: BoxDecoration(
                                color: SurveyTheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: SurveyTheme.border),
                              ),
                              child: const Icon(Icons.analytics_outlined,
                                  size: 24, color: SurveyTheme.textMuted),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              state.error ?? 'Data pipeline uninitialized',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: SurveyTheme.textMain,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'We couldn\'t pull the diagnostic matrix parameters right now.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: SurveyTheme.textMuted,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: SurveyTheme.primaryDark,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: _loadResults,
                                child: Text(
                                  'Re-fetch Dataset',
                                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  color: SurveyTheme.primary,
                  backgroundColor: SurveyTheme.background,
                  onRefresh: _refresh,
                  child: TabBarView(
                    controller: _tabs,
                    children: [
                      SurveyResultsSummaryBody(
                        results: results,
                        state: state,
                        surveyId: widget.surveyId,
                      ),
                      SurveyUserResponsesTab(
                        surveyId: widget.surveyId,
                        responses: state.individualResponses,
                        loading: state.actionInProgress && state.individualResponses.isEmpty,
                        onRefresh: _loadUserResponsesIfNeeded,
                        onDownloadIndividual: (response) {
                          final responseId = response.responseId;
                          if (responseId == null) return Future.value();
                          return SurveyPdfDownload.downloadIndividualReport(
                            context,
                            surveyId: widget.surveyId,
                            responseId: responseId,
                            employeeName: response.employeeName,
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          BlocBuilder<SurveyAdminBloc, SurveyAdminState>(
            builder: (context, state) {
              final detail =
                  state.detail?.id == widget.surveyId ? state.detail : null;
              if (detail?.canDelete != true ||
                  detail?.status != SurveyStatus.closed) {
                return const SizedBox.shrink();
              }
              return Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: SurveyTheme.border)),
                ),
                child: OutlinedButton.icon(
                  onPressed: state.actionInProgress
                      ? null
                      : () => confirmDeleteSurvey(
                            context,
                            survey: detail!,
                            popOnSuccess: true,
                          ),
                  icon: const Icon(Icons.delete_sweep_rounded,
                      color: SurveyTheme.danger, size: 18),
                  label: Text(
                    'Delete closed survey',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SurveyTheme.danger,
                    backgroundColor: SurveyTheme.danger.withValues(alpha: 0.08),
                    side: BorderSide(
                      color: SurveyTheme.danger.withValues(alpha: 0.35),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
        );
      },
    );
  }
}