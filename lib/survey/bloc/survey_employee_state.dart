import 'package:equatable/equatable.dart';

import '../models/survey_models.dart';

enum SurveyEmployeeStatus { initial, loading, success, failure, submitting, submitted }

class SurveyEmployeeState extends Equatable {
  final SurveyEmployeeStatus status;
  final List<SurveySummary> activeSurveys;
  final SurveyDetail? form;
  final SurveyMyResponse? myResponse;
  final String? error;

  const SurveyEmployeeState({
    this.status = SurveyEmployeeStatus.initial,
    this.activeSurveys = const [],
    this.form,
    this.myResponse,
    this.error,
  });

  SurveyEmployeeState copyWith({
    SurveyEmployeeStatus? status,
    List<SurveySummary>? activeSurveys,
    SurveyDetail? form,
    bool clearForm = false,
    SurveyMyResponse? myResponse,
    bool clearMyResponse = false,
    String? error,
    bool clearError = false,
  }) {
    return SurveyEmployeeState(
      status: status ?? this.status,
      activeSurveys: activeSurveys ?? this.activeSurveys,
      form: clearForm ? null : (form ?? this.form),
      myResponse: clearMyResponse ? null : (myResponse ?? this.myResponse),
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [status, activeSurveys, form, myResponse, error];
}
