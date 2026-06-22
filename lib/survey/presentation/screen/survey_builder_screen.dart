import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:my_app/dashboards/presentations/bloc/audience_bloc.dart';

import '../../bloc/survey_admin_bloc.dart';
import '../../bloc/survey_admin_event.dart';
import '../../bloc/survey_admin_state.dart';
import '../../models/survey_models.dart';
import '../../theme/survey_theme.dart';
import '../widgets/survey_delete_action.dart';
import '../widgets/survey_question_editor.dart';
import '../widgets/survey_audience_section.dart';
import 'survey_results_screen.dart';

class SurveyBuilderScreen extends StatefulWidget {
  const SurveyBuilderScreen({super.key, required this.surveyId});

  final int surveyId;

  @override
  State<SurveyBuilderScreen> createState() => _SurveyBuilderScreenState();
}

class _SurveyBuilderScreenState extends State<SurveyBuilderScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _allUsers = true;
  List<int> _deptIds = [];
  List<int> _desigIds = [];
  List<int> _userIds = [];
  int? _syncedSurveyId;

  @override
  void initState() {
    super.initState();
    context.read<SurveyAdminBloc>().add(SurveyAdminLoadDetail(widget.surveyId));
  }

  @override
  void didUpdateWidget(covariant SurveyBuilderScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.surveyId != widget.surveyId) {
      _syncedSurveyId = null;
      _titleCtrl.clear();
      _descCtrl.clear();
      _allUsers = true;
      _deptIds = [];
      _desigIds = [];
      _userIds = [];
      context.read<SurveyAdminBloc>().add(SurveyAdminLoadDetail(widget.surveyId));
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _syncFromDetail(SurveyDetail d) {
    if (d.id != widget.surveyId) return;
    if (_syncedSurveyId == d.id) return;
    _titleCtrl.text = d.title;
    _descCtrl.text = d.description;
    _allUsers = d.isAllUsers;
    _deptIds = List.from(d.targetDepartmentIds);
    _desigIds = List.from(d.targetDesignationIds);
    _userIds = List.from(d.targetUserIds);
    _syncedSurveyId = d.id;
  }

  Map<String, dynamic> _payload() {
    if (!_allUsers) {
      try {
        final t = context.read<AudienceBloc>().resolveCreatePostTargeting();
        return {
          'title': _titleCtrl.text.trim(),
          'description': _descCtrl.text.trim(),
          'is_anonymous': false,
          'is_all_users': false,
          'target_department_ids': t.departmentIds,
          'target_designation_ids': t.designationIds,
          'target_user_ids': t.userIds,
        };
      } catch (_) {}
    }
    return {
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'is_anonymous': false,
        'is_all_users': _allUsers,
        'target_department_ids': _allUsers ? <int>[] : _deptIds,
        'target_designation_ids': _allUsers ? <int>[] : _desigIds,
        'target_user_ids': _allUsers ? <int>[] : _userIds,
      };
  }

  Future<void> _saveMeta() async {
    context.read<SurveyAdminBloc>().add(
          SurveyAdminUpdateRequested(widget.surveyId, _payload()),
        );
  }

  Future<void> _launch() async {
    await _saveMeta();
    if (!mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Launch survey?'),
        content: const Text(
          'Employees will receive a push notification and can respond once.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Launch'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final bloc = context.read<SurveyAdminBloc>();
    bloc.add(SurveyAdminLaunchRequested(widget.surveyId));
    await bloc.stream.firstWhere((s) => !s.actionInProgress);
    if (!mounted) return;
    if (bloc.state.error == null) {
      bloc.add(SurveyAdminLoadResults(widget.surveyId));
      await bloc.stream.firstWhere(
        (s) =>
            s.status != SurveyAdminLoadStatus.loading &&
            (s.results?.surveyId == widget.surveyId || s.status == SurveyAdminLoadStatus.failure),
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: bloc,
            child: SurveyResultsScreen(surveyId: widget.surveyId),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SurveyTheme.background,
      appBar: AppBar(
        backgroundColor: SurveyTheme.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: SurveyTheme.textMain,
        title: Text(
          'Create Survey',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
        ),
        actions: [
          BlocBuilder<SurveyAdminBloc, SurveyAdminState>(
            builder: (context, state) {
              final detail =
                  state.detail?.id == widget.surveyId ? state.detail : null;
              if (detail == null || !detail.canDelete) {
                return const SizedBox.shrink();
              }
              return IconButton(
                onPressed: state.actionInProgress
                    ? null
                    : () => confirmDeleteSurvey(
                          context,
                          survey: detail,
                          popOnSuccess: true,
                        ),
                icon: const Icon(Icons.delete_outline_rounded),
                color: SurveyTheme.textMuted,
                tooltip: 'Delete survey',
              );
            },
          ),
          TextButton(
            onPressed: _saveMeta,
            child: Text(
              'Save draft',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<SurveyAdminBloc, SurveyAdminState>(
        listener: (context, state) {
          final detail = state.detail;
          if (detail != null && detail.id == widget.surveyId) {
            _syncFromDetail(detail);
          }
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        builder: (context, state) {
          final detail =
              state.detail?.id == widget.surveyId ? state.detail : null;
          if (state.status == SurveyAdminLoadStatus.loading && detail == null) {
            return const Center(child: CircularProgressIndicator(color: SurveyTheme.purple));
          }
          if (detail == null) {
            return Center(child: Text(state.error ?? 'Survey not found'));
          }
          final editable = detail.status == SurveyStatus.draft;
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
                children: [
                  _OutlinedField(
                    label: 'Survey Title',
                    controller: _titleCtrl,
                    enabled: editable,
                    hint: 'Untitled Survey',
                  ),
                  const SizedBox(height: 20),
                  _OutlinedField(
                    label: 'Description',
                    controller: _descCtrl,
                    enabled: editable,
                    hint: 'Tell your participants what this survey is about...',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),
                  _SettingCard(
                    icon: Icons.groups_outlined,
                    title: 'All employees',
                    subtitle: 'Send survey to entire organization',
                    value: _allUsers,
                    enabled: editable,
                    onChanged: (v) => setState(() {
                      _allUsers = v;
                      if (v) {
                        _deptIds = [];
                        _desigIds = [];
                        _userIds = [];
                      }
                    }),
                  ),
                  if (!_allUsers) ...[
                    const SizedBox(height: 16),
                    SurveyAudienceSection(
                      allUsers: false,
                      departmentIds: _deptIds,
                      designationIds: _desigIds,
                      userIds: _userIds,
                      enabled: editable,
                      showAllUsersToggle: false,
                      onChanged: (all, d, des, u) => setState(() {
                        _allUsers = all;
                        _deptIds = d;
                        _desigIds = des;
                        _userIds = u;
                      }),
                    ),
                  ],
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Text(
                        'Questions',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          color: SurveyTheme.textMain,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: SurveyTheme.purpleLight,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${detail.questions.length} Items',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: SurveyTheme.purple,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...detail.questions.map(
                    (q) => _QuestionRow(
                      question: q,
                      editable: editable,
                      onTap: editable
                          ? () => openSurveyQuestionEditor(
                                context,
                                surveyId: widget.surveyId,
                                questionId: q.id,
                              )
                          : null,
                      onDelete: () => context.read<SurveyAdminBloc>().add(
                            SurveyAdminDeleteQuestion(widget.surveyId, q.id),
                          ),
                    ),
                  ),
                  if (editable) ...[
                    const SizedBox(height: 8),
                    _AddQuestionArea(
                      onTap: () => showSurveyQuestionAddSheet(
                        context,
                        surveyId: widget.surveyId,
                        nextOrder: detail.questions.length,
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  if (editable) ...[
                    FilledButton.icon(
                      onPressed: state.actionInProgress ? null : _launch,
                      icon: state.actionInProgress
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.send_rounded, size: 20),
                      label: const Text('Launch Survey'),
                      style: FilledButton.styleFrom(
                        backgroundColor: SurveyTheme.purple,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Once launched, you can track real-time analytics in the Overview dashboard. '
                      'Participation links will be sent automatically to the selected audience.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: SurveyTheme.textMuted,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OutlinedField extends StatelessWidget {
  const _OutlinedField({
    required this.label,
    required this.controller,
    this.enabled = true,
    this.hint,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final bool enabled;
  final String? hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      style: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w600,
        fontSize: 15,
        color: SurveyTheme.textMain,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: GoogleFonts.plusJakartaSans(color: SurveyTheme.textMuted),
        labelStyle: GoogleFonts.plusJakartaSans(
          color: SurveyTheme.textMuted,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: SurveyTheme.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: SurveyTheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: SurveyTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: SurveyTheme.purple, width: 1.5),
        ),
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  const _SettingCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SurveyTheme.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: SurveyTheme.purple, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: SurveyTheme.textMain,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: SurveyTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeTrackColor: SurveyTheme.purple.withValues(alpha: 0.45),
            activeThumbColor: SurveyTheme.purple,
          ),
        ],
      ),
    );
  }
}

class _QuestionRow extends StatelessWidget {
  const _QuestionRow({
    required this.question,
    required this.editable,
    required this.onDelete,
    this.onTap,
  });

  final SurveyQuestion question;
  final bool editable;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  String get _typeLabel =>
      questionTypeLabel(question.questionType, allowMultiple: question.allowMultiple);

  String get _metaLabel {
    final parts = <String>[_typeLabel];
    if (question.isRequired) parts.add('Required');
    if (question.allowExplanation) {
      parts.add(question.requireExplanation ? 'Explanation required' : 'Ask explanation');
    }
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final row = Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  question.text,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: SurveyTheme.textMain,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _metaLabel,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: SurveyTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (editable && onTap != null)
            Icon(
              Icons.chevron_right_rounded,
              color: SurveyTheme.textMuted.withValues(alpha: 0.6),
              size: 22,
            ),
          if (editable)
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.close_rounded, size: 20),
              color: SurveyTheme.textMuted,
            ),
        ],
      ),
    );

    if (onTap == null) return row;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: row,
      ),
    );
  }
}

class _AddQuestionArea extends StatelessWidget {
  const _AddQuestionArea({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SurveyTheme.divider),
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: SurveyTheme.purple,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add_rounded, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                'Add Question',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  color: SurveyTheme.purple,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Choose from multiple choice, rating scales, or open-ended text.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: SurveyTheme.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
