import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../bloc/survey_admin_bloc.dart';
import '../../../bloc/survey_admin_event.dart';
import '../../../bloc/survey_admin_state.dart';
import '../../../models/survey_models.dart';
import '../../../theme/survey_mobile_theme.dart';
import '../../widgets/survey_delete_action.dart';
import 'package:my_app/core/widgets/survey_icons.dart';
import 'survey_builder_screen_mobile.dart';
import 'survey_results_screen_mobile.dart';

/// Admin survey dashboard optimized for mobile (terracotta theme).
class SurveyListScreenMobile extends StatelessWidget {
  const SurveyListScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SurveyMobileTheme.screenBg,
      appBar: AppBar(
        backgroundColor: SurveyMobileTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Surveys',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => context
                .read<SurveyAdminBloc>()
                .add(const SurveyAdminRefreshed()),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createSurvey(context),
        backgroundColor: SurveyMobileTheme.primaryDark,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const SurveyIcon(
          type: SurveyIconType.add,
          size: 20,
          color: Colors.white,
        ),
        label: Text(
          'Create',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
        ),
      ),
      body: BlocConsumer<SurveyAdminBloc, SurveyAdminState>(
        listenWhen: (p, c) => c.error != null && c.error != p.error,
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: SurveyMobileTheme.accent,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _FilterBar(
                selected: state.filter,
                onChanged: (s) => context
                    .read<SurveyAdminBloc>()
                    .add(SurveyAdminStatusFilterChanged(s)),
              ),
              Expanded(
                child: RefreshIndicator(
                  color: SurveyMobileTheme.primary,
                  onRefresh: () async {
                    context
                        .read<SurveyAdminBloc>()
                        .add(const SurveyAdminRefreshed());
                  },
                  child: _body(context, state),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _body(BuildContext context, SurveyAdminState state) {
    if (state.status == SurveyAdminLoadStatus.loading && state.surveys.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: SurveyMobileTheme.primary),
      );
    }
    if (state.surveys.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.22),
          const Center(
            child: SurveyIcon(
              type: SurveyIconType.poll,
              size: 40,
              color: SurveyMobileTheme.textMuted,
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              'No surveys yet',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: SurveyMobileTheme.textMain,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Tap Create to start a new survey',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: SurveyMobileTheme.textMuted,
              ),
            ),
          ),
        ],
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      itemCount: state.surveys.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _SurveyCard(
        survey: state.surveys[i],
        onTap: () => _open(context, state.surveys[i]),
        onDelete: () => confirmDeleteSurvey(
          context,
          survey: state.surveys[i],
        ),
      ),
    );
  }

  Future<void> _createSurvey(BuildContext context) async {
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
            child: SurveyBuilderScreenMobile(surveyId: id),
          ),
        ),
      );
    }
  }

  void _open(BuildContext context, SurveySummary survey) {
    final bloc = context.read<SurveyAdminBloc>();
    if (survey.status == SurveyStatus.draft) {
      bloc.add(SurveyAdminLoadDetail(survey.id));
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: bloc,
            child: SurveyBuilderScreenMobile(surveyId: survey.id),
          ),
        ),
      );
    } else {
      bloc.add(SurveyAdminLoadResults(survey.id));
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: bloc,
            child: SurveyResultsScreenMobile(surveyId: survey.id),
          ),
        ),
      );
    }
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.selected,
    required this.onChanged,
  });

  final SurveyStatus? selected;
  final ValueChanged<SurveyStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = <(SurveyStatus?, String, SurveyIconType)>[
      (null, 'All', SurveyIconType.list),
      (SurveyStatus.draft, 'Draft', SurveyIconType.draft),
      (SurveyStatus.active, 'Active', SurveyIconType.active),
      (SurveyStatus.closed, 'Closed', SurveyIconType.closed),
    ];

    return Container(
      color: SurveyMobileTheme.screenBg,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final item in items) ...[
              _FilterChip(
                label: item.$2,
                icon: item.$3,
                selected: selected == item.$1,
                onTap: () => onChanged(item.$1),
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final SurveyIconType icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? SurveyMobileTheme.primary : SurveyMobileTheme.card,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SurveyIcon(
                type: icon,
                size: 16,
                color: selected ? Colors.white : SurveyMobileTheme.primaryDark,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: selected ? Colors.white : SurveyMobileTheme.textMain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SurveyCard extends StatelessWidget {
  const _SurveyCard({
    required this.survey,
    required this.onTap,
    required this.onDelete,
  });

  final SurveySummary survey;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  Color get _badgeColor {
    switch (survey.status) {
      case SurveyStatus.draft:
      case SurveyStatus.unknown:
        return SurveyMobileTheme.textMuted;
      case SurveyStatus.active:
        return SurveyMobileTheme.success;
      case SurveyStatus.closed:
        return SurveyMobileTheme.primaryDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('MMM d · h:mm a');
    final statusLabel =
        survey.status.name[0].toUpperCase() + survey.status.name.substring(1);

    return Material(
      color: SurveyMobileTheme.card,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: SurveyMobileTheme.primary.withValues(alpha: 0.22),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: SurveyMobileTheme.fieldFill,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SurveyIcon(
                  type: survey.status == SurveyStatus.active
                      ? SurveyIconType.active
                      : survey.status == SurveyStatus.closed
                          ? SurveyIconType.closed
                          : SurveyIconType.draft,
                  size: 20,
                  color: SurveyMobileTheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      survey.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: SurveyMobileTheme.textMain,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${survey.responseCount} responses'
                      '${survey.launchedAt != null ? ' · ${df.format(survey.launchedAt!.toLocal())}' : ''}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: SurveyMobileTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _badgeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusLabel,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: _badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (survey.canDelete)
                IconButton(
                  onPressed: onDelete,
                  tooltip: 'Delete survey',
                  icon: const SurveyIcon(
                    type: SurveyIconType.delete,
                    size: 18,
                    color: SurveyMobileTheme.textMuted,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
