import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../bloc/survey_employee_bloc.dart';
import '../../bloc/survey_employee_event.dart';
import '../../bloc/survey_employee_state.dart';
import '../../models/survey_models.dart';
import '../../theme/survey_theme.dart';
import 'package:my_app/admin_dashboard/shared/admin_dashboard_theme.dart';
import 'package:my_app/survey/theme/survey_theme.dart';
import '../widgets/survey_form_fields.dart';
import '../widgets/survey_submission.dart';
import '../widgets/survey_thank_you.dart';

class TakeSurveyScreen extends StatefulWidget {
  const TakeSurveyScreen({super.key, required this.surveyId});

  final int surveyId;

  @override
  State<TakeSurveyScreen> createState() => _TakeSurveyScreenState();
}

class _TakeSurveyScreenState extends State<TakeSurveyScreen> {
  final _answers = <int, dynamic>{};
  final _explanations = <int, String>{};

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final content = BlocConsumer<SurveyEmployeeBloc, SurveyEmployeeState>(
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
          if (form == null) return Center(child: Text(state.error ?? 'Survey unavailable'));
          if (form.alreadySubmitted) {
            return SurveyThankYouView(surveyTitle: form.title);
          }
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(32, 8, 32, 32),
                children: [
                  Text(
                    form.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                      color: SurveyTheme.textMain,
                    ),
                  ),
                  if (form.description.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      form.description,
                      style: GoogleFonts.plusJakartaSans(
                        color: SurveyTheme.textMuted,
                        height: 1.5,
                        fontSize: 14,
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  ...form.questions.map((q) => SurveyFormField(
                        question: q,
                        value: _answers[q.id],
                        explanationValue: _explanations[q.id],
                        onChanged: (v) => setState(() {
                          _answers[q.id] = v;
                          if (!q.isExplanationTriggered(v)) {
                            _explanations.remove(q.id);
                          }
                        }),
                        onExplanationChanged: q.allowExplanation
                            ? (text) => setState(() => _explanations[q.id] = text)
                            : null,
                      )),
                  FilledButton(
                    onPressed: state.form != null &&
                            state.status != SurveyEmployeeStatus.submitting &&
                            state.status != SurveyEmployeeStatus.submitted &&
                            state.status != SurveyEmployeeStatus.loading
                        ? () => _submit(form)
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: SurveyTheme.purple,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: state.status == SurveyEmployeeStatus.submitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            'Submit response',
                            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      );

    if (!wide) {
      return Scaffold(
        backgroundColor: SurveyTheme.employeeShell,
        appBar: AppBar(
          backgroundColor: SurveyTheme.employeeShell,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          foregroundColor: SurveyTheme.textMain,
          title: Text(
            'Survey',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
          ),
        ),
        body: content,
      );
    }

    return Scaffold(
      backgroundColor: SurveyTheme.shell,
      body: Padding(
        padding: const EdgeInsets.all(AdminDashboardTheme.shellPadding),
        child: AdminDashboardPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: SurveyTheme.textMain,
                    ),
                    Text(
                      'Survey',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: SurveyTheme.textMain,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: SurveyTheme.divider),
              Expanded(child: content),
            ],
          ),
        ),
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
