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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Ultra-premium off-white canvas
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 24,
        toolbarHeight: 64,
        // SaaS Border Separation
        shape: Border(bottom: BorderSide(color: const Color(0xFFE2E8F0), width: 1)),
        title: Text(
          'Survey Analytics',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: const Color(0xFF0F172A),
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          BlocBuilder<SurveyAdminBloc, SurveyAdminState>(
            builder: (context, state) {
              final results = _isCurrentResults(state) ? state.results : null;
              final detail = state.detail?.id == widget.surveyId ? state.detail : null;
              if (results == null || detail?.canDelete != true) {
                return const SizedBox.shrink();
              }
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFFEF2F2),
                    highlightColor: const Color(0xFFFEE2E2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    side: const BorderSide(color: Color(0xFFFEE2E2), width: 1),
                    padding: const EdgeInsets.all(10),
                  ),
                  onPressed: state.actionInProgress
                      ? null
                      : () => confirmDeleteSurvey(
                    context,
                    survey: detail!,
                    popOnSuccess: true,
                  ),
                  icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 18),
                  tooltip: 'Delete survey',
                ),
              );
            },
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFEEF2FF),
                highlightColor: const Color(0xFFE0E7FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                side: const BorderSide(color: Color(0xFFE0E7FF), width: 1),
                padding: const EdgeInsets.all(10),
              ),
              onPressed: () => SurveyPdfDownload.downloadFullReport(
                context,
                surveyId: widget.surveyId,
              ),
              icon: const Icon(Icons.download_rounded, color: Color(0xFF4F46E5), size: 18),
              tooltip: 'Download full report',
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 24),
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFF1F5F9),
                highlightColor: const Color(0xFFE2E8F0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
                padding: const EdgeInsets.all(10),
              ),
              onPressed: _refresh,
              icon: const Icon(Icons.refresh_rounded, color: Color(0xFF475569), size: 18),
              tooltip: 'Refresh results',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // High-End Custom Segmented Tab Bar Shell
          Container(
            color: Colors.white,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Container(
              height: 46,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabs,
                labelColor: const Color(0xFF0F172A),
                unselectedLabelColor: const Color(0xFF64748B),
                labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: -0.1),
                unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13),
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                tabs: const [
                  Tab(text: 'Overview Metrics'),
                  Tab(text: 'Respondent Roster'),
                ],
              ),
            ),
          ),

          // Primary content space
          Expanded(
            child: BlocConsumer<SurveyAdminBloc, SurveyAdminState>(
              listenWhen: (p, c) => c.error != null && c.error != p.error,
              listener: (context, state) {
                if (state.error != null && !_isCurrentResults(state)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: const Color(0xFF0F172A),
                      margin: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      content: Text(
                          state.error!,
                          style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14)
                      ),
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state.status == SurveyAdminLoadStatus.loading && !_isCurrentResults(state)) {
                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 56,
                              width: 56,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFF1F5F9)),
                              ),
                              child: const Icon(Icons.analytics_outlined, size: 24, color: Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              state.error ?? 'Data pipeline uninitialized',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'We couldn\'t pull the diagnostic matrix parameters right now.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF64748B),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF0F172A),
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
                  color: const Color(0xFF6366F1),
                  backgroundColor: Colors.white,
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
        ],
      ),
      bottomNavigationBar: BlocBuilder<SurveyAdminBloc, SurveyAdminState>(
        builder: (context, state) {
          final detail = state.detail?.id == widget.surveyId ? state.detail : null;
          if (detail?.canDelete != true || detail?.status != SurveyStatus.closed) {
            return const SizedBox.shrink();
          }
          return SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: const Color(0xFFE2E8F0), width: 1)),
              ),
              child: OutlinedButton.icon(
                onPressed: state.actionInProgress
                    ? null
                    : () => confirmDeleteSurvey(
                  context,
                  survey: detail!,
                  popOnSuccess: true,
                ),
                icon: const Icon(Icons.delete_sweep_rounded, color: Color(0xFFEF4444), size: 18),
                label: Text(
                    'Flush Survey Instance & Metadata',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13)
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFEF4444),
                  backgroundColor: const Color(0xFFFEF2F2),
                  side: const BorderSide(color: Color(0xFFFCA5A5), width: 1),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}