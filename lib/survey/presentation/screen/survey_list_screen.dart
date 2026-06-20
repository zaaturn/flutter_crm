import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../bloc/survey_admin_bloc.dart';
import '../../bloc/survey_admin_event.dart';
import '../../bloc/survey_admin_state.dart';
import '../../models/survey_models.dart';
import '../../theme/survey_theme.dart';
import '../widgets/survey_delete_action.dart';
import 'survey_builder_screen.dart';
import 'survey_results_screen.dart';

class SurveyListScreen extends StatelessWidget {
  const SurveyListScreen({super.key});

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
              _StatusSidebar(
                selected: state.filter,
                onChanged: (s) => context
                    .read<SurveyAdminBloc>()
                    .add(SurveyAdminStatusFilterChanged(s)),
                onCreate: () => _createSurvey(context),
              ),
              const VerticalDivider(width: 1, thickness: 1, color: SurveyTheme.divider),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ListHeader(count: state.surveys.length),
                    Expanded(
                      child: RefreshIndicator(
                        color: SurveyTheme.purple,
                        onRefresh: () async {
                          context.read<SurveyAdminBloc>().add(const SurveyAdminRefreshed());
                        },
                        child: _buildBody(context, state),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, SurveyAdminState state) {
    if (state.status == SurveyAdminLoadStatus.loading && state.surveys.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: SurveyTheme.purple));
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
                Icon(Icons.poll_outlined, size: 48, color: SurveyTheme.textMuted.withValues(alpha: 0.5)),
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
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      itemCount: state.surveys.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: SurveyTheme.divider),
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

class _StatusSidebar extends StatelessWidget {
  const _StatusSidebar({
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
      (null, 'All surveys', Icons.view_list_rounded),
      (SurveyStatus.draft, 'Draft', Icons.edit_note_rounded),
      (SurveyStatus.active, 'Active', Icons.play_circle_outline_rounded),
      (SurveyStatus.closed, 'Closed', Icons.archive_outlined),
    ];

    return SizedBox(
      width: 240,
      child: ColoredBox(
        color: SurveyTheme.background,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 28, 12, 0),
              child: _BackToShareButton(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Text(
                'Surveys',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  color: SurveyTheme.textMain,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilledButton.icon(
                onPressed: onCreate,
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Create Survey'),
                style: FilledButton.styleFrom(
                  backgroundColor: SurveyTheme.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'STATUS',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: SurveyTheme.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...items.map((item) {
              final active = selected == item.$1;
              return _SidebarItem(
                label: item.$2,
                icon: item.$3,
                active: active,
                onTap: () => onChanged(item.$1),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _BackToShareButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.of(context, rootNavigator: true).pop(),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.arrow_back_rounded, size: 20, color: SurveyTheme.textMuted),
              const SizedBox(width: 8),
              Text(
                'Share',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: SurveyTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: active ? SurveyTheme.purpleLight : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: active ? SurveyTheme.purple : SurveyTheme.textMuted,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                    fontSize: 14,
                    color: active ? SurveyTheme.purpleDark : SurveyTheme.textMain,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ListHeader extends StatelessWidget {
  const _ListHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: SurveyTheme.divider)),
      ),
      child: Row(
        children: [
          Text(
            'Survey list',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: SurveyTheme.textMain,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$count item${count == 1 ? '' : 's'}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: SurveyTheme.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
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
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                color: SurveyTheme.textMuted,
                tooltip: 'Delete survey',
              ),
            const Icon(Icons.chevron_right_rounded, color: SurveyTheme.textMuted, size: 20),
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
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
