import 'package:equatable/equatable.dart';

import '../models/survey_models.dart';

abstract class SurveyEmployeeEvent extends Equatable {
  const SurveyEmployeeEvent();
  @override
  List<Object?> get props => [];
}

class SurveyEmployeeLoadActive extends SurveyEmployeeEvent {
  const SurveyEmployeeLoadActive();
}

class SurveyEmployeeLoadForm extends SurveyEmployeeEvent {
  final int surveyId;
  const SurveyEmployeeLoadForm(this.surveyId);
  @override
  List<Object?> get props => [surveyId];
}

class SurveyEmployeeSubmit extends SurveyEmployeeEvent {
  final int surveyId;
  final List<SurveyAnswerPayload> answers;
  const SurveyEmployeeSubmit(this.surveyId, this.answers);
  @override
  List<Object?> get props => [surveyId, answers];
}

class SurveyEmployeeLoadMyResponse extends SurveyEmployeeEvent {
  final int surveyId;
  const SurveyEmployeeLoadMyResponse(this.surveyId);
  @override
  List<Object?> get props => [surveyId];
}

class SurveyEmployeeReset extends SurveyEmployeeEvent {
  const SurveyEmployeeReset();
}
