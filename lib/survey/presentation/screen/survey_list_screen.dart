import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../bloc/survey_admin_bloc.dart';
import '../../bloc/survey_admin_event.dart';
import '../../bloc/survey_admin_state.dart';
import '../../models/survey_models.dart';
import '../../theme/survey_theme.dart';
import '../widgets/survey_admin_shell.dart';
import '../widgets/survey_filter_rail.dart';
import '../widgets/survey_delete_action.dart';
import 'package:my_app/core/widgets/survey_icons.dart';
import 'survey_builder_screen.dart';
import 'survey_results_screen.dart';

class SurveyListScreen extends StatelessWidget {
  const SurveyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SurveyAdminBloc, SurveyAdminState>(
      listenWhen: (p, c) => c.error != null && c.error != p.error,
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        }
      },
      builder: (context, state) {
        return SurveyAdminShell(
          title: 'Surveys',
          subtitle: '${state.surveys.length} item${state.surveys.length == 1 ? '' : 's'}',
          showBackInHeader: false,
          onBack: () => Navigator.of(context, rootNavigator: true).pop(),
          rail: SurveyFilterRail(
            selected: state.filter,
            onCreate: () => _createSurvey(context),
            onBack: () => Navigator.of(context, rootNavigator: true).pop(),
          ),
          body: RefreshIndicator(
            color: SurveyTheme.primary,
            onRefresh: () async {
              context.read<SurveyAdminBloc>().add(const SurveyAdminRefreshed());
            },
            child: _buildBody(context, state),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, SurveyAdminState state) {
    if (state.status == SurveyAdminLoadStatus.loading && state.surveys.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: SurveyTheme.primary),
      );
    }
    if (state.status == SurveyAdminLoadStatus.failure && state.surveys.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          Center(child: Text(state.error ?? 'Failed to load surveys')),
        ],
      );
    }
    if (state.surveys.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          Center(
            child: Column(
              children: [
                SurveyIcon(
                  type: SurveyIconType.poll,
                  size: 48,
                  color: SurveyTheme.textMuted.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  'No surveys in this view',
                  style: GoogleFonts.plusJakartaSans(
                    color: SurveyTheme.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: state.surveys.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: SurveyTheme.divider),
      itemBuilder: (context, i) => _SurveyRow(
        survey: state.surveys[i],
        onTap: () => _openSurvey(context, state.surveys[i]),
        onDelete: () => confirmDeleteSurvey(
          context,
          survey: state.surveys[i],
        ),
      ),
    );
  }

  void _createSurvey(BuildContext context) async {
    final bloc = context.read<SurveyAdminBloc>();
    bloc.add(const SurveyAdminClearSession());
    bloc.add(const SurveyAdminCreateRequested({
      'title': 'Untitled Survey',
      'description': '',
      'is_anonymous': false,
      'is_all_users': true,
      'target_department_ids': <int>[],
      'target_designation_ids': <int>[],
      'target_user_ids': <int>[],
    }));
    await bloc.stream.firstWhere(
      (s) => !s.actionInProgress && (s.detail != null || s.error != null),
    );
    if (!context.mounted) return;
    final id = bloc.state.detail?.id;
    if (id != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: bloc,
            child: SurveyBuilderScreen(surveyId: id),
          ),
        ),
      );
    }
  }

  void _openSurvey(BuildContext context, SurveySummary survey) {
    final bloc = context.read<SurveyAdminBloc>();
    if (survey.status == SurveyStatus.draft) {
      bloc.add(SurveyAdminLoadDetail(survey.id));
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: bloc,
            child: SurveyBuilderScreen(surveyId: survey.id),
          ),
        ),
      );
    } else {
      bloc.add(SurveyAdminLoadResults(survey.id));
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: bloc,
            child: SurveyResultsScreen(surveyId: survey.id),
          ),
        ),
      );
    }
  }
}

class _SurveyRow extends StatelessWidget {
  const _SurveyRow({
    required this.survey,
    required this.onTap,
    required this.onDelete,
  });

  final SurveySummary survey;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('MMM d, yyyy · h:mm a');
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    survey.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: SurveyTheme.textMain,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${survey.responseCount} responses'
                    '${survey.launchedAt != null ? ' · ${df.format(survey.launchedAt!.toLocal())}' : ''}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: SurveyTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            _StatusBadge(status: survey.status),
            if (survey.canDelete)
              IconButton(
                onPressed: onDelete,
                icon: const SurveyIcon(
                  type: SurveyIconType.delete,
                  size: 20,
                  color: SurveyTheme.textMuted,
                ),
                color: SurveyTheme.textMuted,
                tooltip: 'Delete survey',
              ),
            const SurveyIcon(
              type: SurveyIconType.chevronRight,
              size: 20,
              color: SurveyTheme.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final SurveyStatus status;

  @override
  Widget build(BuildContext context) {
    final label = status.name[0].toUpperCase() + status.name.substring(1);
    final color = SurveyTheme.statusColor(statusLikeFromString(status.name));
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
