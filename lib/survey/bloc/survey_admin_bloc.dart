import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/survey_models.dart';
import '../repository/survey_repository.dart';
import '../services/survey_api_service.dart';
import 'survey_admin_event.dart';
import 'survey_admin_state.dart';

class SurveyAdminBloc extends Bloc<SurveyAdminEvent, SurveyAdminState> {
  SurveyAdminBloc({required SurveyRepository repository})
      : _repository = repository,
        super(const SurveyAdminState()) {
    on<SurveyAdminStarted>(_onStarted);
    on<SurveyAdminStatusFilterChanged>(_onFilterChanged);
    on<SurveyAdminRefreshed>(_onRefreshed);
    on<SurveyAdminClearSession>(_onClearSession);
    on<SurveyAdminCreateRequested>(_onCreate);
    on<SurveyAdminLoadDetail>(_onLoadDetail);
    on<SurveyAdminUpdateRequested>(_onUpdate);
    on<SurveyAdminDeleteRequested>(_onDelete);
    on<SurveyAdminAddQuestion>(_onAddQuestion);
    on<SurveyAdminUpdateQuestion>(_onUpdateQuestion);
    on<SurveyAdminDeleteQuestion>(_onDeleteQuestion);
    on<SurveyAdminLaunchRequested>(_onLaunch);
    on<SurveyAdminCloseRequested>(_onClose);
    on<SurveyAdminLoadResults>(_onLoadResults);
    on<SurveyAdminLoadIndividualResponses>(_onLoadIndividual);
  }

  final SurveyRepository _repository;

  Future<void> _onStarted(
    SurveyAdminStarted event,
    Emitter<SurveyAdminState> emit,
  ) async {
    emit(state.copyWith(status: SurveyAdminLoadStatus.loading, clearError: true));
    await _fetchList(emit);
  }

  Future<void> _onFilterChanged(
    SurveyAdminStatusFilterChanged event,
    Emitter<SurveyAdminState> emit,
  ) async {
    emit(state.copyWith(
      filter: event.status,
      status: SurveyAdminLoadStatus.loading,
      clearError: true,
    ));
    await _fetchList(emit);
  }

  Future<void> _onRefreshed(
    SurveyAdminRefreshed event,
    Emitter<SurveyAdminState> emit,
  ) async {
    await _fetchList(emit);
  }

  void _onClearSession(
    SurveyAdminClearSession event,
    Emitter<SurveyAdminState> emit,
  ) {
    emit(state.copyWith(
      clearDetail: true,
      clearResults: true,
      clearIndividualResponses: true,
      clearError: true,
      clearActionMessage: true,
    ));
  }

  Future<void> _fetchList(Emitter<SurveyAdminState> emit) async {
    try {
      final list = await _repository.listSurveys(status: state.filter);
      emit(state.copyWith(
        status: SurveyAdminLoadStatus.success,
        surveys: list,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SurveyAdminLoadStatus.failure,
        error: SurveyApiService.messageFrom(e),
      ));
    }
  }

  Future<void> _onCreate(
    SurveyAdminCreateRequested event,
    Emitter<SurveyAdminState> emit,
  ) async {
    emit(state.copyWith(
      actionInProgress: true,
      clearDetail: true,
      clearResults: true,
      clearIndividualResponses: true,
      clearError: true,
      clearActionMessage: true,
    ));
    try {
      final detail = await _repository.createSurvey(event.body);
      emit(state.copyWith(
        actionInProgress: false,
        detail: detail,
        actionMessage: 'Survey created',
      ));
      add(const SurveyAdminRefreshed());
    } catch (e) {
      emit(state.copyWith(
        actionInProgress: false,
        error: SurveyApiService.messageFrom(e),
      ));
    }
  }

  Future<void> _onLoadDetail(
    SurveyAdminLoadDetail event,
    Emitter<SurveyAdminState> emit,
  ) async {
    emit(state.copyWith(
      status: SurveyAdminLoadStatus.loading,
      clearDetail: true,
      clearResults: true,
      clearIndividualResponses: true,
      clearError: true,
    ));
    try {
      final detail = await _repository.getSurvey(event.surveyId);
      emit(state.copyWith(
        status: SurveyAdminLoadStatus.success,
        detail: detail,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SurveyAdminLoadStatus.failure,
        error: SurveyApiService.messageFrom(e),
      ));
    }
  }

  Future<void> _onUpdate(
    SurveyAdminUpdateRequested event,
    Emitter<SurveyAdminState> emit,
  ) async {
    emit(state.copyWith(actionInProgress: true, clearError: true));
    try {
      final detail = await _repository.updateSurvey(event.surveyId, event.body);
      emit(state.copyWith(actionInProgress: false, detail: detail));
    } catch (e) {
      emit(state.copyWith(
        actionInProgress: false,
        error: SurveyApiService.messageFrom(e),
      ));
    }
  }

  Future<void> _onDelete(
    SurveyAdminDeleteRequested event,
    Emitter<SurveyAdminState> emit,
  ) async {
    final summary = event.survey ?? _surveySummaryFor(event.surveyId);
    if (summary != null && !summary.canDelete) {
      emit(state.copyWith(
        error: summary.status == SurveyStatus.active
            ? 'Active surveys cannot be deleted. Close the survey first.'
            : 'Only draft or closed surveys can be deleted.',
      ));
      return;
    }

    emit(state.copyWith(actionInProgress: true, clearError: true));
    try {
      await _repository.deleteSurvey(event.surveyId);
      emit(state.copyWith(
        actionInProgress: false,
        clearDetail: state.detail?.id == event.surveyId,
        clearResults: state.results?.surveyId == event.surveyId,
        surveys: state.surveys.where((s) => s.id != event.surveyId).toList(),
        actionMessage: 'Survey deleted',
      ));
      add(const SurveyAdminRefreshed());
    } catch (e) {
      emit(state.copyWith(
        actionInProgress: false,
        error: SurveyApiService.messageFrom(e),
      ));
    }
  }

  SurveySummary? _surveySummaryFor(int surveyId) {
    if (state.detail?.id == surveyId) return state.detail;
    for (final survey in state.surveys) {
      if (survey.id == surveyId) return survey;
    }
    return null;
  }

  Future<void> _onAddQuestion(
    SurveyAdminAddQuestion event,
    Emitter<SurveyAdminState> emit,
  ) async {
    emit(state.copyWith(actionInProgress: true, clearError: true));
    try {
      await _repository.addQuestion(event.surveyId, event.body);
      final detail = await _repository.getSurvey(event.surveyId);
      emit(state.copyWith(actionInProgress: false, detail: detail));
    } catch (e) {
      emit(state.copyWith(
        actionInProgress: false,
        error: SurveyApiService.messageFrom(e),
      ));
    }
  }

  Future<void> _onUpdateQuestion(
    SurveyAdminUpdateQuestion event,
    Emitter<SurveyAdminState> emit,
  ) async {
    emit(state.copyWith(actionInProgress: true, clearError: true));
    try {
      await _repository.updateQuestion(
        event.surveyId,
        event.questionId,
        event.body,
      );
      final detail = await _repository.getSurvey(event.surveyId);
      emit(state.copyWith(actionInProgress: false, detail: detail));
    } catch (e) {
      emit(state.copyWith(
        actionInProgress: false,
        error: SurveyApiService.messageFrom(e),
      ));
    }
  }

  Future<void> _onDeleteQuestion(
    SurveyAdminDeleteQuestion event,
    Emitter<SurveyAdminState> emit,
  ) async {
    emit(state.copyWith(actionInProgress: true, clearError: true));
    try {
      await _repository.deleteQuestion(event.surveyId, event.questionId);
      final detail = await _repository.getSurvey(event.surveyId);
      emit(state.copyWith(actionInProgress: false, detail: detail));
    } catch (e) {
      emit(state.copyWith(
        actionInProgress: false,
        error: SurveyApiService.messageFrom(e),
      ));
    }
  }

  Future<void> _onLaunch(
    SurveyAdminLaunchRequested event,
    Emitter<SurveyAdminState> emit,
  ) async {
    emit(state.copyWith(actionInProgress: true, clearError: true));
    try {
      final detail = await _repository.launchSurvey(event.surveyId);
      emit(state.copyWith(
        actionInProgress: false,
        detail: detail,
        actionMessage: 'Survey launched',
      ));
      add(const SurveyAdminRefreshed());
    } on DioException catch (e) {
      emit(state.copyWith(
        actionInProgress: false,
        error: SurveyApiService.messageFrom(e),
      ));
    } catch (e) {
      emit(state.copyWith(
        actionInProgress: false,
        error: SurveyApiService.messageFrom(e),
      ));
    }
  }

  Future<void> _onClose(
    SurveyAdminCloseRequested event,
    Emitter<SurveyAdminState> emit,
  ) async {
    emit(state.copyWith(actionInProgress: true, clearError: true));
    try {
      final detail = await _repository.closeSurvey(event.surveyId);
      emit(state.copyWith(
        actionInProgress: false,
        detail: detail,
        actionMessage: 'Survey closed',
      ));
      add(const SurveyAdminRefreshed());
    } catch (e) {
      emit(state.copyWith(
        actionInProgress: false,
        error: SurveyApiService.messageFrom(e),
      ));
    }
  }

  Future<void> _onLoadResults(
    SurveyAdminLoadResults event,
    Emitter<SurveyAdminState> emit,
  ) async {
    emit(state.copyWith(
      status: SurveyAdminLoadStatus.loading,
      clearResults: true,
      clearIndividualResponses: true,
      clearError: true,
    ));
    try {
      final detail = await _repository.getSurvey(event.surveyId);
      if (emit.isDone) return;
      final results = await _repository.getResults(event.surveyId);
      if (emit.isDone) return;
      final enriched = results.enrichWithDetail(detail);
      emit(state.copyWith(
        status: SurveyAdminLoadStatus.success,
        results: enriched,
        detail: detail,
        individualResponses: enriched.userResponses,
      ));
    } catch (e) {
      if (emit.isDone) return;
      emit(state.copyWith(
        status: SurveyAdminLoadStatus.failure,
        error: SurveyApiService.messageFrom(e),
        clearResults: true,
      ));
    }
  }

  Future<void> _onLoadIndividual(
    SurveyAdminLoadIndividualResponses event,
    Emitter<SurveyAdminState> emit,
  ) async {
    emit(state.copyWith(actionInProgress: true, clearError: true));
    try {
      final rows = await _repository.getIndividualResponses(event.surveyId);
      emit(state.copyWith(
        actionInProgress: false,
        individualResponses: rows,
      ));
    } on DioException catch (e) {
      emit(state.copyWith(
        actionInProgress: false,
        error: SurveyApiService.messageFrom(e),
      ));
    } catch (e) {
      emit(state.copyWith(
        actionInProgress: false,
        error: SurveyApiService.messageFrom(e),
      ));
    }
  }
}
