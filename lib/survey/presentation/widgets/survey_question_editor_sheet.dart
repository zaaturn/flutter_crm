import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/survey_admin_bloc.dart';
import '../../bloc/survey_admin_event.dart';
import '../../models/survey_models.dart';
import '../../theme/survey_mobile_theme.dart';
import '../../theme/survey_theme.dart';

Future<void> showSurveyQuestionEditorSheet(
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
        child: _QuestionEditor(
          surveyId: surveyId,
          nextOrder: nextOrder,
          mobile: mobile,
        ),
      ),
    ),
  );
}

class _QuestionEditor extends StatefulWidget {
  const _QuestionEditor({
    required this.surveyId,
    required this.nextOrder,
    required this.mobile,
  });

  final int surveyId;
  final int nextOrder;
  final bool mobile;

  @override
  State<_QuestionEditor> createState() => _QuestionEditorState();
}

class _QuestionEditorState extends State<_QuestionEditor> {
  QuestionType _type = QuestionType.yesNo;
  final _textCtrl = TextEditingController();
  bool _required = true;
  bool _allowMultiple = false;
  bool _saving = false;
  final _optionCtrls = [TextEditingController(), TextEditingController()];

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _save() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) {
      _toast('Enter question text');
      return;
    }
    final body = <String, dynamic>{
      'text': text,
      'question_type': questionTypeToApi(_type),
      'is_required': _required,
      'order': widget.nextOrder,
    };
    if (_type == QuestionType.mcq) {
      body['allow_multiple'] = _allowMultiple;
      body['options'] = _optionCtrls
          .map((c) => c.text.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      if ((body['options'] as List).length < 2) {
        _toast('Add at least 2 MCQ options');
        return;
      }
    }

    setState(() => _saving = true);
    final bloc = context.read<SurveyAdminBloc>();
    final beforeCount = bloc.state.detail?.questions.length ?? 0;
    bloc.add(SurveyAdminAddQuestion(widget.surveyId, body));

    try {
      // Wait for in-flight save (skip matching idle state before handler runs).
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
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    for (final c in _optionCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _addOption() => setState(() => _optionCtrls.add(TextEditingController()));

  @override
  Widget build(BuildContext context) {
    final accent = widget.mobile ? SurveyMobileTheme.primaryDark : SurveyTheme.purple;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          Text('Add Question', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(height: 12),
          TextField(
            controller: _textCtrl,
            decoration: const InputDecoration(labelText: 'Question text'),
          ),
          const SizedBox(height: 12),
          SegmentedButton<QuestionType>(
            segments: const [
              ButtonSegment(value: QuestionType.yesNo, label: Text('Yes/No')),
              ButtonSegment(value: QuestionType.rating, label: Text('Rating')),
              ButtonSegment(value: QuestionType.mcq, label: Text('MCQ')),
            ],
            selected: {_type},
            onSelectionChanged: (s) => setState(() => _type = s.first),
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
            ..._optionCtrls.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextField(controller: c, decoration: const InputDecoration(labelText: 'Option')),
                )),
            TextButton(onPressed: _addOption, child: const Text('Add option')),
          ],
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(backgroundColor: accent),
            child: _saving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Save Question'),
          ),
        ],
        ),
      ),
    );
  }
}
