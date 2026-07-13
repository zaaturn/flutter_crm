import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../bloc/survey_admin_bloc.dart';
import '../../../bloc/survey_admin_event.dart';
import '../../../bloc/survey_admin_state.dart';
import '../../../models/survey_models.dart';
import '../../../theme/survey_theme.dart';
import '../../widgets/survey_delete_action.dart';
import 'package:my_app/core/widgets/app_material_icon.dart';
import 'package:my_app/core/widgets/survey_icons.dart';
import 'survey_builder_screen_mobile.dart';
import 'survey_results_screen_mobile.dart';

class SurveyListScreenMobile extends StatelessWidget {
  const SurveyListScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SurveyTheme.background,
      body: BlocConsumer<SurveyAdminBloc, SurveyAdminState>(
        listenWhen: (p, c) => c.error != null && c.error != p.error,
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        },
        builder: (context, state) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _MobileSidebar(
                selected: state.filter,
                onChanged: (s) => context
                    .read<SurveyAdminBloc>()
                    .add(SurveyAdminStatusFilterChanged(s)),
                onCreate: () => _createSurvey(context),
              ),
              const VerticalDivider(width: 1, color: SurveyTheme.divider),
              Expanded(
                child: RefreshIndicator(
                  color: SurveyTheme.purple,
                  onRefresh: () async {
                    context.read<SurveyAdminBloc>().add(const SurveyAdminRefreshed());
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
        child: CircularProgressIndicator(color: SurveyTheme.purple),
      );
    }
    if (state.surveys.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 100),
          Center(
            child: Text(
              'No surveys yet',
              style: GoogleFonts.plusJakartaSans(color: SurveyTheme.textMuted),
            ),
          ),
        ],
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: state.surveys.length,
      separatorBuilder: (_, __) => const SizedBox.shrink(),
      itemBuilder: (context, i) => _Card(
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

class _MobileSidebar extends StatelessWidget {
  const _MobileSidebar({
    required this.selected,
    required this.onChanged,
    required this.onCreate,
  });

  final SurveyStatus? selected;
  final ValueChanged<SurveyStatus?> onChanged;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final items = <(SurveyStatus?, String, IconData)>[
      (null, 'All', Icons.list_alt_outlined),
      (SurveyStatus.draft, 'Draft', Icons.edit_note_outlined),
      (SurveyStatus.active, 'Active', Icons.play_circle_outline),
      (SurveyStatus.closed, 'Closed', Icons.inventory_2_outlined),
    ];

    return SizedBox(
      width: 108,
      child: ColoredBox(
        color: SurveyTheme.background,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: IconButton(
                  onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                  icon: const SurveyIcon(
                    type: SurveyIconType.arrowBack,
                    size: 20,
                    color: SurveyTheme.textMain,
                  ),
                  color: SurveyTheme.textMain,
                  tooltip: 'Back to Share',
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Text(
                  'Surveys',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: SurveyTheme.textMain,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: IconButton.filled(
                  onPressed: onCreate,
                  icon: const SurveyIcon(
                    type: SurveyIconType.add,
                    size: 20,
                    color: Colors.white,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: SurveyTheme.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...items.map((item) {
                final active = selected == item.$1;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: Material(
                    color: active ? SurveyTheme.purpleLight : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () => onChanged(item.$1),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          children: [
                            AppMaterialIcon(
                              item.$3,
                              size: 18,
                              color: active ? SurveyTheme.purple : SurveyTheme.textMuted,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.$2,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: active ? SurveyTheme.purpleDark : SurveyTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.survey,
    required this.onTap,
    required this.onDelete,
  });

  final SurveySummary survey;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('MMM d · h:mm a');
    final badgeColor = SurveyTheme.statusColor(statusLikeFromString(survey.status.name));
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: SurveyTheme.divider)),
        ),
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
                      fontSize: 14,
                      color: SurveyTheme.textMain,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${survey.responseCount} responses'
                    '${survey.launchedAt != null ? ' · ${df.format(survey.launchedAt!.toLocal())}' : ''}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: SurveyTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                survey.status.name[0].toUpperCase() + survey.status.name.substring(1),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: badgeColor,
                ),
              ),
            ),
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
          ],
        ),
      ),
    );
  }
}
