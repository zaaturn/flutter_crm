import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../bloc/survey_admin_bloc.dart';
import '../../bloc/survey_admin_event.dart';
import '../../models/survey_models.dart';
import '../../repository/survey_repository.dart';
import '../../services/survey_api_service.dart';
import '../../theme/survey_mobile_theme.dart';
import '../../theme/survey_theme.dart';

/// Bottom sheet for adding a new question (draft surveys only).
Future<void> showSurveyQuestionAddSheet(
  BuildContext context, {
  required int surveyId,
  required int nextOrder,
  bool mobile = false,
}) async {
  final bloc = context.read<SurveyAdminBloc>();
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: mobile ? SurveyMobileTheme.background : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => BlocProvider.value(
      value: bloc,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: SurveyQuestionEditorPage(
          surveyId: surveyId,
          nextOrder: nextOrder,
          mobile: mobile,
          embeddedInSheet: true,
        ),
      ),
    ),
  );
}

/// Full-screen editor — loads question via GET, saves with PATCH.
Future<void> openSurveyQuestionEditor(
  BuildContext context, {
  required int surveyId,
  required int questionId,
  bool mobile = false,
}) async {
  final bloc = context.read<SurveyAdminBloc>();
  await Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: SurveyQuestionEditorPage(
          surveyId: surveyId,
          questionId: questionId,
          nextOrder: 0,
          mobile: mobile,
        ),
      ),
    ),
  );
}

class SurveyQuestionEditorPage extends StatefulWidget {
  const SurveyQuestionEditorPage({
    super.key,
    required this.surveyId,
    this.questionId,
    required this.nextOrder,
    this.mobile = false,
    this.embeddedInSheet = false,
  });

  final int surveyId;
  final int? questionId;
  final int nextOrder;
  final bool mobile;
  final bool embeddedInSheet;

  bool get isEdit => questionId != null;

  @override
  State<SurveyQuestionEditorPage> createState() => _SurveyQuestionEditorPageState();
}

class _SurveyQuestionEditorPageState extends State<SurveyQuestionEditorPage> {
  final _repository = SurveyRepository();
  final _textCtrl = TextEditingController();
  final _explanationPromptCtrl = TextEditingController(text: 'Please explain your answer');

  QuestionType _type = QuestionType.yesNo;
  bool _required = true;
  bool _allowMultiple = false;
  bool _allowExplanation = false;
  bool _requireExplanation = false;
  bool _saving = false;
  bool _loading = false;
  String? _loadError;
  int _order = 0;
  List<TextEditingController> _optionCtrls = [
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      _loadQuestion();
    } else {
      _order = widget.nextOrder;
    }
  }

  Future<void> _loadQuestion() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final q = await _repository.getQuestion(widget.surveyId, widget.questionId!);
      if (!mounted) return;
      _applyQuestion(q);
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = SurveyApiService.messageFrom(e);
      });
    }
  }

  void _applyQuestion(SurveyQuestion q) {
    _textCtrl.text = q.text;
    _type = q.questionType;
    _required = q.isRequired;
    _allowMultiple = q.allowMultiple;
    _allowExplanation = q.allowExplanation;
    _requireExplanation = q.requireExplanation;
    _explanationPromptCtrl.text = q.explanationPrompt;
    _order = q.order;

    for (final c in _optionCtrls) {
      c.dispose();
    }
    if (q.questionType == QuestionType.mcq && q.options.isNotEmpty) {
      _optionCtrls = q.options.map((o) => TextEditingController(text: o.text)).toList();
    } else {
      _optionCtrls = [TextEditingController(), TextEditingController()];
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Map<String, dynamic>? _buildBody() {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) {
      _toast('Enter question text');
      return null;
    }
    final body = <String, dynamic>{
      'text': text,
      'question_type': questionTypeToApi(_type),
      'is_required': _required,
      'order': _order,
    };
    if (_type == QuestionType.mcq) {
      body['allow_multiple'] = _allowMultiple;
      body['options'] = _optionCtrls
          .map((c) => c.text.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      if ((body['options'] as List).length < 2) {
        _toast('Add at least 2 MCQ options');
        return null;
      }
    }
    if (_type != QuestionType.text) {
      body['allow_explanation'] = _allowExplanation;
      if (_allowExplanation) {
        body['require_explanation'] = _requireExplanation;
        final prompt = _explanationPromptCtrl.text.trim();
        body['explanation_prompt'] =
            prompt.isEmpty ? 'Please explain your answer' : prompt;
      } else {
        body['require_explanation'] = false;
      }
    }
    return body;
  }

  Future<void> _save() async {
    final body = _buildBody();
    if (body == null) return;

    setState(() => _saving = true);
    final bloc = context.read<SurveyAdminBloc>();

    if (widget.isEdit) {
      bloc.add(SurveyAdminUpdateQuestion(widget.surveyId, widget.questionId!, body));
    } else {
      final beforeCount = bloc.state.detail?.questions.length ?? 0;
      bloc.add(SurveyAdminAddQuestion(widget.surveyId, body));

      try {
        if (!bloc.state.actionInProgress) {
          await bloc.stream.firstWhere((s) => s.actionInProgress);
        }
        await bloc.stream.firstWhere((s) => !s.actionInProgress);

        if (!mounted) return;
        final err = bloc.state.error;
        final afterCount = bloc.state.detail?.questions.length ?? 0;
        if (err != null) {
          _toast(err);
          setState(() => _saving = false);
          return;
        }
        if (afterCount <= beforeCount) {
          _toast('Question was not added. Check survey is still in draft.');
          setState(() => _saving = false);
          return;
        }
        Navigator.pop(context);
      } catch (_) {
        if (mounted) {
          _toast('Could not save question');
          setState(() => _saving = false);
        }
      }
      return;
    }

    try {
      if (!bloc.state.actionInProgress) {
        await bloc.stream.firstWhere((s) => s.actionInProgress);
      }
      await bloc.stream.firstWhere((s) => !s.actionInProgress);

      if (!mounted) return;
      final err = bloc.state.error;
      if (err != null) {
        _toast(err);
        setState(() => _saving = false);
        return;
      }
      Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        _toast('Could not save question');
        setState(() => _saving = false);
      }
    }
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _explanationPromptCtrl.dispose();
    for (final c in _optionCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _addOption() => setState(() => _optionCtrls.add(TextEditingController()));

  Widget _buildForm() {
    final accent = widget.mobile ? SurveyMobileTheme.primaryDark : SurveyTheme.purple;

    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(48),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_loadError!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: _loadQuestion, child: const Text('Retry')),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, widget.embeddedInSheet ? 20 : 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.embeddedInSheet)
            Text(
              'Add Question',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900, fontSize: 18),
            ),
          if (widget.embeddedInSheet) const SizedBox(height: 12),
          TextField(
            controller: _textCtrl,
            decoration: const InputDecoration(labelText: 'Question text'),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final entry in const [
                (QuestionType.yesNo, 'Yes/No'),
                (QuestionType.rating, 'Rating'),
                (QuestionType.mcq, 'MCQ'),
                (QuestionType.text, 'Descriptive text'),
              ])
                FilterChip(
                  label: Text(entry.$2),
                  selected: _type == entry.$1,
                  onSelected: (_) => setState(() {
                    _type = entry.$1;
                    if (_type == QuestionType.text) {
                      _allowExplanation = false;
                      _requireExplanation = false;
                    }
                  }),
                ),
            ],
          ),
          SwitchListTile(
            value: _required,
            onChanged: (v) => setState(() => _required = v),
            title: const Text('Required'),
          ),
          if (_type == QuestionType.mcq) ...[
            SwitchListTile(
              value: _allowMultiple,
              onChanged: (v) => setState(() => _allowMultiple = v),
              title: const Text('Allow multiple selections'),
            ),
            ..._optionCtrls.map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextField(
                  controller: c,
                  decoration: const InputDecoration(labelText: 'Option'),
                ),
              ),
            ),
            TextButton(onPressed: _addOption, child: const Text('Add option')),
          ],
          if (_type != QuestionType.text) ...[
            SwitchListTile(
              value: _allowExplanation,
              onChanged: (v) => setState(() {
                _allowExplanation = v;
                if (!v) _requireExplanation = false;
              }),
              title: const Text('Ask for explanation'),
              subtitle: const Text('Show a follow-up text box after the employee answers'),
            ),
            if (_allowExplanation) ...[
              SwitchListTile(
                value: _requireExplanation,
                onChanged: (v) => setState(() => _requireExplanation = v),
                title: const Text('Explanation required'),
              ),
              TextField(
                controller: _explanationPromptCtrl,
                decoration: const InputDecoration(
                  labelText: 'Explanation prompt',
                  hintText: 'Please explain your answer',
                ),
              ),
              const SizedBox(height: 8),
            ],
          ],
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(
              backgroundColor: accent,
              minimumSize: const Size.fromHeight(48),
            ),
            child: _saving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(widget.isEdit ? 'Save changes' : 'Save Question'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embeddedInSheet) {
      return _buildForm();
    }

    final bg = widget.mobile ? SurveyMobileTheme.background : SurveyTheme.background;
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.isEdit ? 'Edit question' : 'Add question',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
        ),
      ),
      body: _buildForm(),
    );
  }
}
