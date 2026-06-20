import 'package:flutter_bloc/flutter_bloc.dart';



import '../models/survey_models.dart';

import '../repository/survey_repository.dart';

import '../services/survey_api_service.dart';

import 'survey_employee_event.dart';

import 'survey_employee_state.dart';



class SurveyEmployeeBloc extends Bloc<SurveyEmployeeEvent, SurveyEmployeeState> {

  SurveyEmployeeBloc({required SurveyRepository repository})

      : _repository = repository,

        super(const SurveyEmployeeState()) {

    on<SurveyEmployeeLoadActive>(_onLoadActive);

    on<SurveyEmployeeLoadForm>(_onLoadForm);

    on<SurveyEmployeeSubmit>(_onSubmit);

    on<SurveyEmployeeLoadMyResponse>(_onLoadMyResponse);

    on<SurveyEmployeeReset>(_onReset);

  }



  final SurveyRepository _repository;



  List<SurveySummary> _sortActiveSurveys(List<SurveySummary> surveys) {

    final sorted = List<SurveySummary>.from(surveys);

    sorted.sort((a, b) {

      if (a.alreadySubmitted != b.alreadySubmitted) {

        return a.alreadySubmitted ? 1 : -1;

      }

      final aDate = a.launchedAt ?? DateTime.fromMillisecondsSinceEpoch(0);

      final bDate = b.launchedAt ?? DateTime.fromMillisecondsSinceEpoch(0);

      return bDate.compareTo(aDate);

    });

    return sorted;

  }



  Future<void> _onLoadActive(

    SurveyEmployeeLoadActive event,

    Emitter<SurveyEmployeeState> emit,

  ) async {

    emit(state.copyWith(
      status: SurveyEmployeeStatus.loading,
      activeSurveys: const [],
      clearError: true,
    ));

    try {

      final list = await _repository.getActiveSurveys();

      if (emit.isDone) return;

      emit(state.copyWith(

        status: SurveyEmployeeStatus.success,

        activeSurveys: _sortActiveSurveys(list),

      ));

    } catch (e) {

      if (emit.isDone) return;

      emit(state.copyWith(

        status: SurveyEmployeeStatus.failure,

        error: SurveyApiService.messageFrom(e),

      ));

    }

  }



  Future<void> _onLoadForm(

    SurveyEmployeeLoadForm event,

    Emitter<SurveyEmployeeState> emit,

  ) async {

    emit(state.copyWith(

      status: SurveyEmployeeStatus.loading,

      clearError: true,

      clearForm: true,

      clearMyResponse: true,

    ));

    try {

      final form = await _repository.getSurveyForm(event.surveyId);

      if (emit.isDone) return;

      emit(state.copyWith(

        status: SurveyEmployeeStatus.success,

        form: form,

        clearMyResponse: true,

      ));

    } catch (e) {

      if (emit.isDone) return;

      emit(state.copyWith(

        status: SurveyEmployeeStatus.failure,

        error: SurveyApiService.messageFrom(e),

        clearForm: true,

      ));

    }

  }



  Future<void> _onSubmit(

    SurveyEmployeeSubmit event,

    Emitter<SurveyEmployeeState> emit,

  ) async {

    emit(state.copyWith(status: SurveyEmployeeStatus.submitting, clearError: true));

    try {

      await _repository.submitSurvey(event.surveyId, event.answers);

      if (emit.isDone) return;

      emit(state.copyWith(

        status: SurveyEmployeeStatus.submitted,

        clearError: true,

      ));

    } catch (e) {

      if (emit.isDone) return;

      emit(state.copyWith(

        status: SurveyEmployeeStatus.success,

        error: SurveyApiService.messageFrom(e),

      ));

    }

  }



  Future<void> _onLoadMyResponse(

    SurveyEmployeeLoadMyResponse event,

    Emitter<SurveyEmployeeState> emit,

  ) async {

    try {

      final my = await _repository.getMyResponse(event.surveyId);

      if (emit.isDone) return;

      emit(state.copyWith(myResponse: my));

    } catch (e) {

      if (emit.isDone) return;

      emit(state.copyWith(error: SurveyApiService.messageFrom(e)));

    }

  }



  void _onReset(

    SurveyEmployeeReset event,

    Emitter<SurveyEmployeeState> emit,

  ) {

    emit(const SurveyEmployeeState());

  }

}

