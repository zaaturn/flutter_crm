import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../bloc/survey_employee_bloc.dart';
import '../../../bloc/survey_employee_event.dart';
import '../../../bloc/survey_employee_state.dart';
import '../../../models/survey_models.dart';
import '../../../theme/survey_theme.dart';
import '../../widgets/survey_form_fields.dart';
import '../../widgets/survey_submission.dart';
import '../../widgets/survey_thank_you.dart';

class TakeSurveyScreenMobile extends StatefulWidget {
  const TakeSurveyScreenMobile({super.key, required this.surveyId});

  final int surveyId;

  @override
  State<TakeSurveyScreenMobile> createState() => _TakeSurveyScreenMobileState();
}

class _TakeSurveyScreenMobileState extends State<TakeSurveyScreenMobile> {
  final _answers = <int, dynamic>{};
  final _explanations = <int, String>{};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: SurveyTheme.textMain,
        title: Text('Survey', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
      ),
      bottomNavigationBar: BlocBuilder<SurveyEmployeeBloc, SurveyEmployeeState>(
        builder: (context, state) {
          final form = state.form;
          final readonly = form?.alreadySubmitted == true;
          final canSubmit = form != null &&
              !readonly &&
              state.status != SurveyEmployeeStatus.submitting &&
              state.status != SurveyEmployeeStatus.submitted &&
              state.status != SurveyEmployeeStatus.loading;
          if (readonly || form == null) return const SizedBox.shrink();
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: ElevatedButton(
                onPressed: canSubmit ? () => _submit(form) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SurveyTheme.purple,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: state.status == SurveyEmployeeStatus.submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text('Submit response', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700)),
              ),
            ),
          );
        },
      ),
      body: BlocConsumer<SurveyEmployeeBloc, SurveyEmployeeState>(
        listenWhen: (prev, curr) =>
            prev.status != curr.status && curr.status == SurveyEmployeeStatus.submitted ||
            (curr.error != null && prev.error != curr.error),
        listener: (context, state) {
          if (state.status == SurveyEmployeeStatus.submitted) {
            Navigator.of(context).pop(true);
            return;
          }
          if (state.error != null) {
            surveySnack()(state.error!);
          }
        },
        builder: (context, state) {
          if (state.status == SurveyEmployeeStatus.loading && state.form == null) {
            return const Center(child: CircularProgressIndicator(color: SurveyTheme.purple));
          }
          final form = state.form;
          if (form == null) {
            return Center(child: Text(state.error ?? 'Survey unavailable'));
          }
          if (form.alreadySubmitted) {
            return SurveyThankYouView(surveyTitle: form.title, mobile: true);
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Text(
                form.title,
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 22),
              ),
              if (form.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  form.description,
                  style: GoogleFonts.plusJakartaSans(color: SurveyTheme.textMuted, height: 1.4),
                ),
              ],
              const SizedBox(height: 20),
              ...form.questions.map(
                (q) => SurveyFormField(
                  question: q,
                  value: _answers[q.id],
                  explanationValue: _explanations[q.id],
                  mobile: true,
                  onChanged: (v) => setState(() {
                    _answers[q.id] = v;
                    if (!q.isExplanationTriggered(v)) {
                      _explanations.remove(q.id);
                    }
                  }),
                  onExplanationChanged: q.allowExplanation
                      ? (text) => setState(() => _explanations[q.id] = text)
                      : null,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _submit(SurveyDetail form) {
    final payloads = buildSurveyAnswerPayloads(
      form: form,
      answers: _answers,
      explanations: _explanations,
      showMessage: surveySnack(),
    );
    if (payloads == null) return;
    context.read<SurveyEmployeeBloc>().add(SurveyEmployeeSubmit(widget.surveyId, payloads));
  }
}
