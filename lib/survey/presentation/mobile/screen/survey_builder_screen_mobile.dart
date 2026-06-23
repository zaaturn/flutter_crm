import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:my_app/dashboards/presentations/bloc/audience_bloc.dart';

import '../../../bloc/survey_admin_bloc.dart';
import '../../../bloc/survey_admin_event.dart';
import '../../../bloc/survey_admin_state.dart';
import '../../../models/survey_models.dart';
import '../../../theme/survey_mobile_theme.dart';
import '../../../theme/survey_theme.dart';
import '../../widgets/survey_question_editor.dart';
import '../../widgets/survey_audience_section.dart';
import 'survey_results_screen_mobile.dart';

class SurveyBuilderScreenMobile extends StatefulWidget {
  const SurveyBuilderScreenMobile({super.key, required this.surveyId});

  final int surveyId;

  @override
  State<SurveyBuilderScreenMobile> createState() => _SurveyBuilderScreenMobileState();
}

class _SurveyBuilderScreenMobileState extends State<SurveyBuilderScreenMobile> {
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
  void didUpdateWidget(covariant SurveyBuilderScreenMobile oldWidget) {
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

  void _sync(SurveyDetail d) {
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

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: SurveyMobileTheme.fieldFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SurveyTheme.background,
      appBar: AppBar(
        backgroundColor: SurveyTheme.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text('Build Survey', style: GoogleFonts.manrope(fontWeight: FontWeight.w900)),
      ),
      bottomNavigationBar: BlocBuilder<SurveyAdminBloc, SurveyAdminState>(
        builder: (context, state) {
          final detail =
              state.detail?.id == widget.surveyId ? state.detail : null;
          final editable = detail?.status == SurveyStatus.draft;
          if (!editable) return const SizedBox.shrink();
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: ElevatedButton(
                onPressed: state.actionInProgress ? null : () => _launch(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SurveyMobileTheme.primaryDark,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Launch Survey', style: GoogleFonts.manrope(fontWeight: FontWeight.w900)),
              ),
            ),
          );
        },
      ),
      body: BlocConsumer<SurveyAdminBloc, SurveyAdminState>(
        listener: (context, state) {
          final detail = state.detail;
          if (detail != null && detail.id == widget.surveyId) {
            _sync(detail);
          }
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!), backgroundColor: SurveyMobileTheme.accent),
            );
          }
        },
        builder: (context, state) {
          final detail =
              state.detail?.id == widget.surveyId ? state.detail : null;
          if (detail == null && state.status == SurveyAdminLoadStatus.loading) {
            return const Center(child: CircularProgressIndicator(color: SurveyMobileTheme.primary));
          }
          if (detail == null) return Center(child: Text(state.error ?? 'Not found'));
          final editable = detail.status == SurveyStatus.draft;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              TextField(
                controller: _titleCtrl,
                enabled: editable,
                style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 18),
                decoration: _dec('Survey title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descCtrl,
                enabled: editable,
                maxLines: 3,
                decoration: _dec('Description'),
              ),
              const SizedBox(height: 8),
              SurveyAudienceSection(
                allUsers: _allUsers,
                departmentIds: _deptIds,
                designationIds: _desigIds,
                userIds: _userIds,
                enabled: editable,
                mobile: true,
                onChanged: (all, d, des, u) => setState(() {
                  _allUsers = all;
                  _deptIds = d;
                  _desigIds = des;
                  _userIds = u;
                }),
              ),
              const SizedBox(height: 16),
              Text('Questions', style: GoogleFonts.manrope(fontWeight: FontWeight.w900, fontSize: 16)),
              const SizedBox(height: 10),
              ...detail.questions.map((q) {
                final card = Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: SurveyMobileTheme.card,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(q.text, style: GoogleFonts.manrope(fontWeight: FontWeight.w800)),
                            Text(
                              [
                                questionTypeLabel(q.questionType, allowMultiple: q.allowMultiple),
                                if (q.isRequired) 'Required',
                                if (q.allowExplanation)
                                  q.requireExplanation ? 'Explanation required' : 'Ask explanation',
                              ].join(' · '),
                              style: GoogleFonts.manrope(
                                fontSize: 12,
                                color: SurveyMobileTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (editable) ...[
                        Icon(
                          Icons.chevron_right_rounded,
                          color: SurveyMobileTheme.textMuted.withValues(alpha: 0.6),
                        ),
                        IconButton(
                          onPressed: () => context.read<SurveyAdminBloc>().add(
                                SurveyAdminDeleteQuestion(widget.surveyId, q.id),
                              ),
                          icon: const Icon(Icons.delete_outline_rounded),
                        ),
                      ],
                    ],
                  ),
                );
                if (!editable) return card;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => openSurveyQuestionEditor(
                      context,
                      surveyId: widget.surveyId,
                      questionId: q.id,
                      mobile: true,
                    ),
                    child: card,
                  ),
                );
              }),
              if (editable)
                OutlinedButton.icon(
                  onPressed: () => showSurveyQuestionAddSheet(
                    context,
                    surveyId: widget.surveyId,
                    nextOrder: detail.questions.length,
                    mobile: true,
                  ),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add Question'),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _launch(BuildContext context) async {
    context.read<SurveyAdminBloc>().add(
          SurveyAdminUpdateRequested(widget.surveyId, _payload()),
        );
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Launch survey?'),
        content: const Text('Push notifications will be sent to targeted employees.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Launch')),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final bloc = context.read<SurveyAdminBloc>();
    bloc.add(SurveyAdminLaunchRequested(widget.surveyId));
    await bloc.stream.firstWhere((s) => !s.actionInProgress);
    if (!context.mounted) return;
    if (bloc.state.error == null) {
      bloc.add(SurveyAdminLoadResults(widget.surveyId));
      await bloc.stream.firstWhere(
        (s) =>
            s.status != SurveyAdminLoadStatus.loading &&
            (s.results?.surveyId == widget.surveyId || s.status == SurveyAdminLoadStatus.failure),
      );
      if (!context.mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: bloc,
            child: SurveyResultsScreenMobile(surveyId: widget.surveyId),
          ),
        ),
      );
    }
  }
}
