import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:my_app/core/scaffold_messenger_scope.dart';
import 'package:my_app/survey/models/survey_models.dart';
import 'package:my_app/survey/utils/survey_word_count.dart';

typedef SurveySnack = void Function(String message);

SurveySnack surveySnack([dynamic context]) {
  return (message) {
    rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  };
}

void showSurveySuccessSnack({
  String message = 'Survey taken successfully',
  String? title,
}) {
  final label = title == null || title.isEmpty
      ? message
      : '$message — $title';

  rootScaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF10B981),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      duration: const Duration(seconds: 3),
      content: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

List<SurveyAnswerPayload>? buildSurveyAnswerPayloads({
  required SurveyDetail form,
  required Map<int, dynamic> answers,
  Map<int, String> explanations = const {},
  required SurveySnack showMessage,
}) {
  final payloads = <SurveyAnswerPayload>[];

  for (final q in form.questions) {
    if (q.questionType == QuestionType.unknown || q.id <= 0) continue;

    final v = answers[q.id];
    final isEmptyMulti = (v is List && v.isEmpty) || (v is Set && v.isEmpty);
    final isEmptyText = q.questionType == QuestionType.text &&
        (v == null || (v is String && v.trim().isEmpty));
    if (q.isRequired && (v == null || isEmptyMulti || isEmptyText)) {
      showMessage('Please answer: ${q.text}');
      return null;
    }
    if (v == null) continue;

    final explanation = (explanations[q.id] ?? '').trim();
    if (q.allowExplanation && q.supportsExplanation) {
      if (q.requireExplanation && explanation.isEmpty) {
        showMessage('${q.effectiveExplanationPrompt} (required)');
        return null;
      }
      if (explanation.isNotEmpty &&
          surveyWordCount(explanation) > q.explanationMaxWords) {
        showMessage('Explanation for "${q.text}" exceeds ${q.explanationMaxWords} words.');
        return null;
      }
    }

    switch (q.questionType) {
      case QuestionType.yesNo:
        payloads.add(SurveyAnswerPayload(
          questionId: q.id,
          yesNoValue: v as bool,
          explanationText: explanation.isEmpty ? null : explanation,
        ));
      case QuestionType.rating:
        payloads.add(SurveyAnswerPayload(
          questionId: q.id,
          ratingValue: v as int,
          explanationText: explanation.isEmpty ? null : explanation,
        ));
      case QuestionType.text:
        final text = (v as String).trim();
        if (text.isEmpty) {
          if (q.isRequired) {
            showMessage('Please answer: ${q.text}');
            return null;
          }
          continue;
        }
        if (surveyWordCount(text) > q.maxWords) {
          showMessage('Answer for "${q.text}" exceeds ${q.maxWords} words.');
          return null;
        }
        payloads.add(SurveyAnswerPayload(questionId: q.id, textValue: text));
      case QuestionType.mcq:
        final optionIds = q.allowMultiple
            ? (v is Set
                ? (v as Set).map((e) => e is int ? e : int.tryParse('$e') ?? 0).toList()
                : (v is List ? List<int>.from(v as List) : <int>[]))
            : [v is int ? v : int.tryParse('$v') ?? 0];
        if (optionIds.isEmpty || optionIds.every((id) => id <= 0)) {
          if (q.isRequired) {
            showMessage('Please answer: ${q.text}');
            return null;
          }
          continue;
        }
        payloads.add(SurveyAnswerPayload(
          questionId: q.id,
          selectedOptionIds: optionIds,
          explanationText: explanation.isEmpty ? null : explanation,
        ));
      case QuestionType.unknown:
        break;
    }
  }

  if (payloads.isEmpty) {
    showMessage('Please answer at least one question.');
    return null;
  }

  return payloads;
}
