import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../bloc/survey_admin_bloc.dart';
import '../../../bloc/survey_admin_event.dart';
import '../../../bloc/survey_admin_state.dart';
import '../../../models/survey_models.dart';
import '../../../theme/survey_mobile_theme.dart';
import '../../widgets/survey_delete_action.dart';
import '../../widgets/survey_results_summary_body.dart';
import '../../widgets/survey_user_responses_tab.dart';
import '../../../utils/survey_pdf_download.dart';

class SurveyResultsScreenMobile extends StatefulWidget {
  const SurveyResultsScreenMobile({super.key, required this.surveyId});

  final int surveyId;

  @override
  State<SurveyResultsScreenMobile> createState() => _SurveyResultsScreenMobileState();
}

class _SurveyResultsScreenMobileState extends State<SurveyResultsScreenMobile>
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
    return Scaffold(
      backgroundColor: SurveyMobileTheme.screenBg,
      appBar: AppBar(
        backgroundColor: SurveyMobileTheme.primary,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Results',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: () => SurveyPdfDownload.downloadFullReport(
              context,
              surveyId: widget.surveyId,
            ),
            icon: const Icon(Icons.download_rounded),
            tooltip: 'Download full report',
          ),
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
                tooltip: 'Delete survey',
              );
            },
          ),
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: 'Summary'),
            Tab(text: 'User responses'),
          ],
        ),
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

          return RefreshIndicator(
            color: SurveyMobileTheme.primary,
            onRefresh: _refresh,
            child: TabBarView(
              controller: _tabs,
              children: [
                SurveyResultsSummaryBody(
                  results: results,
                  state: state,
                  surveyId: widget.surveyId,
                  mobile: true,
                ),
                SurveyUserResponsesTab(
                  surveyId: widget.surveyId,
                  responses: state.individualResponses,
                  loading: state.actionInProgress && state.individualResponses.isEmpty,
                  mobile: true,
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
    );
  }
}
