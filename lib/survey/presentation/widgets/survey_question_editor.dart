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

class _McqOptionField {
  _McqOptionField({String text = '', this.triggersExplanation = false})
      : controller = TextEditingController(text: text);

  final TextEditingController controller;
  bool triggersExplanation;

  void dispose() => controller.dispose();
}

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
    builder: (ctx) {
      final sheetHeight = MediaQuery.sizeOf(ctx).height * 0.92;
      return BlocProvider.value(
        value: bloc,
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
          child: SizedBox(
            height: sheetHeight,
            child: SurveyQuestionEditorPage(
              surveyId: surveyId,
              nextOrder: nextOrder,
              mobile: mobile,
              embeddedInSheet: true,
            ),
          ),
        ),
      );
    },
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
  final _explanationMaxWordsCtrl = TextEditingController(text: '250');

  QuestionType _type = QuestionType.yesNo;
  bool _required = true;
  bool _allowMultiple = false;
  bool _allowExplanation = false;
  bool _requireExplanation = false;
  bool _explanationIfEnabled = false;
  String _explanationIfYesNo = 'yes';
  bool _saving = false;
  bool _loading = false;
  String? _loadError;
  int _order = 0;
  List<_McqOptionField> _mcqOptions = [_McqOptionField(), _McqOptionField()];

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
    _explanationMaxWordsCtrl.text = '${q.explanationMaxWords}';
    _explanationIfEnabled = q.explanationIfEnabled;
    _explanationIfYesNo =
        q.explanationIfYesNo == 'no' ? 'no' : 'yes';
    _order = q.order;

    for (final o in _mcqOptions) {
      o.dispose();
    }
    if (q.questionType == QuestionType.mcq && q.options.isNotEmpty) {
      _mcqOptions = q.options
          .map((o) => _McqOptionField(
                text: o.text,
                triggersExplanation: o.triggersExplanation,
              ))
          .toList();
    } else {
      _mcqOptions = [_McqOptionField(), _McqOptionField()];
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
      final options = _mcqOptions
          .map((o) => {
                'text': o.controller.text.trim(),
                'triggers_explanation': o.triggersExplanation,
              })
          .where((o) => (o['text'] as String).isNotEmpty)
          .toList();
      if (options.length < 2) {
        _toast('Add at least 2 MCQ options');
        return null;
      }
      if (_allowExplanation &&
          _explanationIfEnabled &&
          !options.any((o) => o['triggers_explanation'] == true)) {
        _toast('Turn on IF explanation for at least one MCQ option');
        return null;
      }
      body['options'] = options;
    }
    if (_type != QuestionType.text) {
      body['allow_explanation'] = _allowExplanation;
      if (_allowExplanation) {
        body['require_explanation'] = _requireExplanation;
        final prompt = _explanationPromptCtrl.text.trim();
        body['explanation_prompt'] =
            prompt.isEmpty ? 'Please explain your answer' : prompt;
        final maxWords = int.tryParse(_explanationMaxWordsCtrl.text.trim());
        body['explanation_max_words'] = (maxWords != null && maxWords > 0) ? maxWords : 250;
        body['explanation_if_enabled'] = _explanationIfEnabled;
        if (_explanationIfEnabled && _type == QuestionType.yesNo) {
          body['explanation_if_yes_no'] = _explanationIfYesNo;
        } else {
          body['explanation_if_yes_no'] = '';
        }
      } else {
        body['require_explanation'] = false;
        body['explanation_if_enabled'] = false;
        body['explanation_if_yes_no'] = '';
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
    _explanationMaxWordsCtrl.dispose();
    for (final o in _mcqOptions) {
      o.dispose();
    }
    super.dispose();
  }

  void _addOption() => setState(() => _mcqOptions.add(_McqOptionField()));

  Color get _accent => widget.mobile ? SurveyMobileTheme.primaryDark : SurveyTheme.purple;

  Widget _saveButton() {
    return FilledButton(
      onPressed: _saving ? null : _save,
      style: FilledButton.styleFrom(
        backgroundColor: _accent,
        minimumSize: const Size.fromHeight(48),
      ),
      child: _saving
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : Text(widget.isEdit ? 'Save changes' : 'Save Question'),
    );
  }

  Widget _buildExplanationSection() {
    if (_type == QuestionType.text || !_allowExplanation) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _requireExplanation,
          onChanged: (v) => setState(() => _requireExplanation = v),
          title: const Text('Require explanation'),
        ),
        TextField(
          controller: _explanationPromptCtrl,
          decoration: const InputDecoration(
            labelText: 'Explanation prompt',
            hintText: 'Please explain your answer',
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _explanationMaxWordsCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Max words',
            hintText: '250',
          ),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _explanationIfEnabled,
          onChanged: (v) => setState(() => _explanationIfEnabled = v),
          title: const Text('IF condition'),
          subtitle: const Text(
            'When on, the explanation box opens only for the answer or option you select below',
          ),
        ),
        if (_explanationIfEnabled && _type == QuestionType.yesNo) ...[
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            value: _explanationIfYesNo,
            decoration: const InputDecoration(
              labelText: 'Open explanation when employee selects',
            ),
            items: const [
              DropdownMenuItem(value: 'yes', child: Text('Yes')),
              DropdownMenuItem(value: 'no', child: Text('No')),
            ],
            onChanged: (v) {
              if (v != null) setState(() => _explanationIfYesNo = v);
            },
          ),
          const SizedBox(height: 8),
        ],
        if (_explanationIfEnabled && _type == QuestionType.rating) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Explanation opens after the employee selects any rating.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ],
    );
  }

  List<Widget> _buildFormFields() {
    return [
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
                  _explanationIfEnabled = false;
                }
              }),
            ),
        ],
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: _required,
        onChanged: (v) => setState(() => _required = v),
        title: const Text('Required'),
      ),
      if (_type == QuestionType.mcq) ...[
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _allowMultiple,
          onChanged: (v) => setState(() => _allowMultiple = v),
          title: const Text('Allow multiple selections'),
        ),
        ..._mcqOptions.asMap().entries.map((entry) {
          final idx = entry.key;
          final field = entry.value;
          final showOptionFlag = _allowExplanation && _explanationIfEnabled;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: field.controller,
                  decoration: InputDecoration(labelText: 'Option ${idx + 1}'),
                ),
                if (showOptionFlag)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: field.triggersExplanation,
                    onChanged: (v) =>
                        setState(() => field.triggersExplanation = v == true),
                    title: const Text(
                      'Opens explanation',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
              ],
            ),
          );
        }),
        TextButton(onPressed: _addOption, child: const Text('Add option')),
      ],
      if (_type != QuestionType.text) ...[
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _allowExplanation,
          onChanged: (v) => setState(() {
            _allowExplanation = v;
            if (!v) {
              _requireExplanation = false;
              _explanationIfEnabled = false;
            }
          }),
          title: const Text('Allow explanation'),
          subtitle: const Text('Show a follow-up text box after the employee answers'),
        ),
        _buildExplanationSection(),
      ],
    ];
  }

  Widget _buildBodyContent() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_loadError!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: _loadQuestion, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (widget.embeddedInSheet) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _buildFormFields(),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: _saveButton(),
            ),
          ),
        ],
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ..._buildFormFields(),
          const SizedBox(height: 12),
          _saveButton(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embeddedInSheet) {
      return _buildBodyContent();
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
      body: _buildBodyContent(),
    );
  }
}
