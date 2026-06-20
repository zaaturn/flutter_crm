import 'package:equatable/equatable.dart';

import '../models/survey_models.dart';

abstract class SurveyAdminEvent extends Equatable {
  const SurveyAdminEvent();
  @override
  List<Object?> get props => [];
}

class SurveyAdminStarted extends SurveyAdminEvent {
  const SurveyAdminStarted();
}

class SurveyAdminStatusFilterChanged extends SurveyAdminEvent {
  final SurveyStatus? status;
  const SurveyAdminStatusFilterChanged(this.status);
  @override
  List<Object?> get props => [status];
}

class SurveyAdminRefreshed extends SurveyAdminEvent {
  const SurveyAdminRefreshed();
}

/// Clears cached detail/results so a new survey session starts fresh.
class SurveyAdminClearSession extends SurveyAdminEvent {
  const SurveyAdminClearSession();
}

class SurveyAdminCreateRequested extends SurveyAdminEvent {
  final Map<String, dynamic> body;
  const SurveyAdminCreateRequested(this.body);
  @override
  List<Object?> get props => [body];
}

class SurveyAdminLoadDetail extends SurveyAdminEvent {
  final int surveyId;
  const SurveyAdminLoadDetail(this.surveyId);
  @override
  List<Object?> get props => [surveyId];
}

class SurveyAdminUpdateRequested extends SurveyAdminEvent {
  final int surveyId;
  final Map<String, dynamic> body;
  const SurveyAdminUpdateRequested(this.surveyId, this.body);
  @override
  List<Object?> get props => [surveyId, body];
}

class SurveyAdminDeleteRequested extends SurveyAdminEvent {
  final int surveyId;
  final SurveySummary? survey;

  const SurveyAdminDeleteRequested(this.surveyId, {this.survey});

  @override
  List<Object?> get props => [surveyId, survey];
}

class SurveyAdminAddQuestion extends SurveyAdminEvent {
  final int surveyId;
  final Map<String, dynamic> body;
  const SurveyAdminAddQuestion(this.surveyId, this.body);
  @override
  List<Object?> get props => [surveyId, body];
}

class SurveyAdminUpdateQuestion extends SurveyAdminEvent {
  final int surveyId;
  final int questionId;
  final Map<String, dynamic> body;
  const SurveyAdminUpdateQuestion(this.surveyId, this.questionId, this.body);
  @override
  List<Object?> get props => [surveyId, questionId, body];
}

class SurveyAdminDeleteQuestion extends SurveyAdminEvent {
  final int surveyId;
  final int questionId;
  const SurveyAdminDeleteQuestion(this.surveyId, this.questionId);
  @override
  List<Object?> get props => [surveyId, questionId];
}

class SurveyAdminLaunchRequested extends SurveyAdminEvent {
  final int surveyId;
  const SurveyAdminLaunchRequested(this.surveyId);
  @override
  List<Object?> get props => [surveyId];
}

class SurveyAdminCloseRequested extends SurveyAdminEvent {
  final int surveyId;
  const SurveyAdminCloseRequested(this.surveyId);
  @override
  List<Object?> get props => [surveyId];
}

class SurveyAdminLoadResults extends SurveyAdminEvent {
  final int surveyId;
  const SurveyAdminLoadResults(this.surveyId);
  @override
  List<Object?> get props => [surveyId];
}

class SurveyAdminLoadIndividualResponses extends SurveyAdminEvent {
  final int surveyId;
  const SurveyAdminLoadIndividualResponses(this.surveyId);
  @override
  List<Object?> get props => [surveyId];
}
