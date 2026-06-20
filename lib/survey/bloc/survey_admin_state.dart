import 'package:equatable/equatable.dart';

import '../models/survey_models.dart';

enum SurveyAdminLoadStatus { initial, loading, success, failure, saving }

class SurveyAdminState extends Equatable {
  final SurveyAdminLoadStatus status;
  final SurveyStatus? filter;
  final List<SurveySummary> surveys;
  final SurveyDetail? detail;
  final SurveyResults? results;
  final List<SurveyIndividualResponse> individualResponses;
  final String? error;
  final String? actionMessage;
  final bool actionInProgress;

  const SurveyAdminState({
    this.status = SurveyAdminLoadStatus.initial,
    this.filter,
    this.surveys = const [],
    this.detail,
    this.results,
    this.individualResponses = const [],
    this.error,
    this.actionMessage,
    this.actionInProgress = false,
  });

  SurveyAdminState copyWith({
    SurveyAdminLoadStatus? status,
    SurveyStatus? filter,
    bool clearFilter = false,
    List<SurveySummary>? surveys,
    SurveyDetail? detail,
    bool clearDetail = false,
    SurveyResults? results,
    bool clearResults = false,
    List<SurveyIndividualResponse>? individualResponses,
    bool clearIndividualResponses = false,
    String? error,
    bool clearError = false,
    String? actionMessage,
    bool clearActionMessage = false,
    bool? actionInProgress,
  }) {
    return SurveyAdminState(
      status: status ?? this.status,
      filter: clearFilter ? null : (filter ?? this.filter),
      surveys: surveys ?? this.surveys,
      detail: clearDetail ? null : (detail ?? this.detail),
      results: clearResults ? null : (results ?? this.results),
      individualResponses: clearIndividualResponses
          ? const []
          : (individualResponses ?? this.individualResponses),
      error: clearError ? null : (error ?? this.error),
      actionMessage: clearActionMessage ? null : (actionMessage ?? this.actionMessage),
      actionInProgress: actionInProgress ?? this.actionInProgress,
    );
  }

  @override
  List<Object?> get props => [
        status,
        filter,
        surveys,
        detail,
        results,
        individualResponses,
        error,
        actionMessage,
        actionInProgress,
      ];
}
